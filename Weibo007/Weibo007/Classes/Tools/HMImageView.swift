//
//  HMProgressView.swift
//  01-进度视图
//
//  Created by apple on 15/7/6.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class HMImageView: UIImageView {
    
    /// 进度 0.0-1.0
    var progress: CGFloat = 0 {
        didSet {
            if progress > 0 {
                progressView.progress = progress
            }
        }
    }
    
    // 进度视图 [weak self] 表示闭包内部的 self 是`弱引用`
    // [unowned self] 表示闭包内部的 self `不做强引用`
    private lazy var progressView: HMProgressView = { [unowned self] in
        let v = HMProgressView()
        
        self.addSubview(v)
        v.ff_Fill(self)
        
        return v
    }()
    
    /// 嵌套的私有类，仅供 HMImageView 使用
    private class HMProgressView: UIView {
        
        /// 进度 0.0-1.0
        var progress: CGFloat = 0 {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            backgroundColor = UIColor.clearColor()
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func drawRect(rect: CGRect) {
            
            if progress == 0 || progress == 1 {
                return
            }
            
            // 0. 准备
            let r = min(rect.width, rect.height) * 0.4
            let center = CGPoint(x: rect.width * 0.5, y: rect.height * 0.5)
            let ovalRect = CGRect(x: center.x - r, y: center.y - r, width: 2 * r, height: 2 * r)
            
            // 1. 画圆
            let path1 = UIBezierPath(ovalInRect: ovalRect)
            UIColor(white: 1.0, alpha: 0.5).setFill()
            path1.fill()
            
            // 2. 画圆弧
            let start = CGFloat(-M_PI_2)
            let end = CGFloat(2 * M_PI) * progress + start
            
            let path2 = UIBezierPath(arcCenter: center, radius: r, startAngle: start, endAngle: end, clockwise: true)
            path2.addLineToPoint(center)
            path2.closePath()
            
            UIColor(white: 0.0, alpha: 0.5).setFill()
            path2.fill()
        }
    }
}

