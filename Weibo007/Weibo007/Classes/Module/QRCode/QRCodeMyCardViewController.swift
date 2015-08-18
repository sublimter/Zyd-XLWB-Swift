//
//  QRCodeMyCardViewController.swift
//  Weibo007
//
//  Created by apple on 15/6/29.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class QRCodeMyCardViewController: UIViewController {

    lazy var iconView: UIImageView = UIImageView()
    
    override func loadView() {
        view = UIView()
        
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(iconView)
        iconView.ff_AlignInner(ff_AlignType.CenterCenter, referView: view, size: CGSize(width: 200, height: 200))
        iconView.backgroundColor = UIColor.lightGrayColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 提示，如果视图的背景颜色为 nil，会严重影响视图的`渲染`性能
        // view.backgroundColor = UIColor.whiteColor()
        iconView.image = generateQRCodeImage()
        
        // 打印系统内置的所有滤镜
        print(CIFilter.filterNamesInCategory(kCICategoryBuiltIn))
    }

    /**
        CI  Core Image: 滤镜 / GIF / 二维码是 iOS 7.0 添加到滤镜中的
        使用
        1. 使用名称创建
        2. setDefaults()
        3. KVC 设置内容，可以百度
        4. outputImage 获取结果 CIImage
    
        CG  Core Graphics: 核心绘图，绘制图形，路径，ShapeLayer，核心动画
    */
    private func generateQRCodeImage() -> UIImage {
        
        // 1. 建立二维码滤镜
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")!
        
        // 2. 设置成初始值
        qrFilter.setDefaults()
        
        // 3. 通过 KVC 设置滤镜信息
        qrFilter.setValue("我就是刀哥".dataUsingEncoding(NSUTF8StringEncoding), forKey: "inputMessage")
        
        // 4. 获取结果
        let ciImage = qrFilter.outputImage
        
        // 5. 生成图片的大小 27 * 27 / 23 * 23，不清楚
        print(ciImage.extent)
        
        // 6 放大图片
        let transform = CGAffineTransformMakeScale(15, 15)
        let transformImage = ciImage.imageByApplyingTransform(transform)
        print("转换的图像大小 \(transformImage.extent)")
        
        // 7. 颜色滤镜
        let colorFilter = CIFilter(name: "CIFalseColor")!
        colorFilter.setDefaults()
        colorFilter.setValue(transformImage, forKey: "inputImage")
        // 前景色
        colorFilter.setValue(CIColor(color: UIColor.blackColor()), forKey: "inputColor0")
        // 背景色
        colorFilter.setValue(CIColor(color: UIColor.whiteColor()), forKey: "inputColor1")
        
        let resultImage = colorFilter.outputImage
        let avatar = UIImage(named: "avatar")!
        return insertAvatarImage(UIImage(CIImage: resultImage), avatar: avatar)
    }
    
    // 在二维码图像中间增加一个头像
    /**
        二维码有很强的容错性
        - 能够遮挡部分，也可以破损部分，但是，不能破坏或者遮挡定位点！
    */
    private func insertAvatarImage(image: UIImage, avatar: UIImage) -> UIImage {
    
        // 1. 开启绘图上下文，和二维码图像相同大小
        UIGraphicsBeginImageContext(image.size)
    
        // 2. 绘图
        let rect = CGRect(origin: CGPointZero, size: image.size)
        image.drawInRect(rect)
        
        // 添加头像
        let w = rect.width * 0.25
        let x = (rect.width - w) * 0.5
        let y = (rect.height - w) * 0.5
        avatar.drawInRect(CGRect(x: x, y: y, width: w, height: w))
        
        // 3. `先`取得结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        // 4. `后`关闭上下文
        UIGraphicsEndImageContext()
        
        // 5. 返回结果
        return result
    }
}
