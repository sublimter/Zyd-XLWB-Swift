//
//  QRCodeViewController.swift
//  Weibo007
//
//  Created by apple on 15/6/29.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, UITabBarDelegate, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    /// 顶部约束
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    /// 结果标签
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var scanImage: UIImageView!
    
    ///  关闭视图控制器
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    ///  显示我的名片
    @IBAction func showMyCard() {
        navigationController?.pushViewController(QRCodeMyCardViewController(), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 默认选中第一项
        tabBar.selectedItem = tabBar.items![0]
        
        // 设置二维码扫描环境
        setupSession()
        setupLayers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        startAnimation()
        
        // 开始扫描
        startScan()
    }
    
    func startAnimation() {
        topConstraint.constant = -heightConstraint.constant
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(2.0) { () -> Void in
            // 重复次数需要放在内部
            UIView.setAnimationRepeatCount(MAXFLOAT)
            
            // 添加了修改的标记
            self.topConstraint.constant = self.heightConstraint.constant
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - TabBar 代理方法
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        print(item.tag)
        // 调整高度
        heightConstraint.constant = widthConstraint.constant * (item.tag == 1 ? 0.5 : 1)
        
        // 停止动画 - 核心动画将动画添加到图层
        scanImage.layer.removeAllAnimations()
        
        // 重新开始动画
        startAnimation()
    }
    
    // MARK: - 二维码扫描
    ///  开始扫描
    func startScan() {
        session.startRunning()
    }
    
    ///  设置图层
    private func setupLayers() {
        // 1. 设置绘图图层
        drawLayer.frame = view.bounds
        view.layer.insertSublayer(drawLayer, atIndex: 0)
        
        // 2. 预览图层－设定图层大小
        previewLayer.frame = view.bounds
        // 设置图层填充模式
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        // 将图层添加到当前图层
        view.layer.insertSublayer(previewLayer, atIndex: 0)
    }
    
    ///  设置会话
    private func setupSession() {
        // 1. 判断能否添加输入设备
        if !session.canAddInput(inputDevice) {
            print("无法添加输入设备")
            return
        }
        
        // 2. 判断能否添加输出数据
        if !session.canAddOutput(outputData) {
            print("无法添加输出数据")
            return
        }
        
        // 3. 添加设备
        session.addInput(inputDevice)
        print("前 \(outputData.availableMetadataObjectTypes)")
        session.addOutput(outputData)
        // 只有添加到 session 之后，输出数据的数据类型才可用
        print("后 \(outputData.availableMetadataObjectTypes)")
        
        // 4. 设置检测数据类型，检测所有支持的数据格式
        outputData.metadataObjectTypes = outputData.availableMetadataObjectTypes
        
        // 5. 设置数据的代理
        outputData.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // 清空图层
        clearDrawLayer()
        
        for object in metadataObjects {
            // 判断识别对象类型
            if object is AVMetadataMachineReadableCodeObject {
                // 转换数据类型
                let codeObject = previewLayer.transformedMetadataObjectForMetadataObject(object as! AVMetadataObject) as! AVMetadataMachineReadableCodeObject

                drawCorners(codeObject)
                resultLabel.text = codeObject.stringValue
            }
        }
    }
    
    ///  清空绘图图层
    private func clearDrawLayer() {
        // 如果没有子图层，直接返回
        if drawLayer.sublayers == nil {
            return
        }
        
        for subLayer in drawLayer.sublayers! {
            subLayer.removeFromSuperlayer()
        }
    }
    
    ///  绘制变现形状
    private func drawCorners(codeObject: AVMetadataMachineReadableCodeObject) {
        print(codeObject)
        
        // 可以做动画绘图的，专门在图层中画图
        let layer = CAShapeLayer()
        layer.lineWidth = 4
        layer.strokeColor = UIColor.greenColor().CGColor
        layer.fillColor = UIColor.clearColor().CGColor
        
        // 是一个 包含 CFDictionaries 的 NSArray
        layer.path = createPath(codeObject.corners).CGPath
        
        drawLayer.addSublayer(layer)
    }
    
    private func createPath(corners: NSArray) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        // 定义 Point UnsafeMutablePointer -> var
        var point = CGPoint()
        var index = 0
        // 拿到第 0 个点
        CGPointMakeWithDictionaryRepresentation(corners[index++] as! CFDictionary, &point)
        // 移动到第 0 个点
        path.moveToPoint(point)
        
        // 遍历剩余的点
        while index < corners.count {
            CGPointMakeWithDictionaryRepresentation(corners[index++] as! CFDictionary, &point)
            // 添加路线
            path.addLineToPoint(point)
        }
        
        // 关闭路径
        path.closePath()
        
        return path
    }
    
    // MARK: - 懒加载
    // 绘图图层
    lazy var drawLayer: CALayer = CALayer()
    
    // 预览视图 - 依赖与session的
    lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
    
    // session 桥梁
    lazy var session: AVCaptureSession = AVCaptureSession()
    // 输入设备
    lazy var inputDevice: AVCaptureDeviceInput? = {
        // 取摄像头设备
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch {
            print(error)
            return nil
        }
    }()
    // 输出数据
    lazy var outputData: AVCaptureMetadataOutput = AVCaptureMetadataOutput()
}
