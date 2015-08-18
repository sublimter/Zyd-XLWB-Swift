//
//  UIImage+Extension.swift
//  01-照片选择
//
//  Created by apple on 15/7/10.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

extension UIImage {
    
    ///  将图片缩放到指定宽度
    func scaleImage(width: CGFloat) -> UIImage {
        
        // 1. 计算实际缩放尺寸
        let height = size.height * width / size.width

        // 2. 利用核心绘图来缩放图像
        let s = CGSize(width: width, height: height)
        
        // 1> 上下文 
        UIGraphicsBeginImageContext(s)
        
        // 2> 绘制图像
        drawInRect(CGRect(origin: CGPointZero, size: s))
        
        // 3> 从上下文获取结果
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        // 4> 关闭上下文
        UIGraphicsEndImageContext()
        
        return result
    }
}
