//
//  UIBarButtonItem+Extension.swift
//  Weibo007
//
//  Created by apple on 15/6/29.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    
    // convenience 方便的
    // 为了满足导航按钮有高亮图片的需求，同时如果美工按照 高亮图片命名 _highlighted，程序能够更加简单！
    convenience init(imageName: String, highlightedImageName: String?) {
        let btn = UIButton()

        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal);
        // ?? 表示如果前面的内容为 nil，使用后面的内容
        let hImageName = highlightedImageName ?? imageName + "_highlighted"
        
        btn.setImage(UIImage(named: hImageName), forState: UIControlState.Highlighted)
        
        btn.sizeToFit()
        print(btn.frame)
        
        self.init(customView: btn)
    }
    
    ///  创建 UIBarButtonItem
    ///
    ///  :param: imageName            图像名
    ///  :param: highlightedImageName 高亮名，可以为 nil
    ///  :param: target               target
    ///  :param: actionName           actionName
    convenience init(imageName: String, highlightedImageName: String?, target: AnyObject?, actionName: String?) {
        
        let btn = UIButton()
        
        btn.setImage(UIImage(named: imageName), forState: UIControlState.Normal);
        
        let hImageName = highlightedImageName ?? imageName + "_highlighted"
        btn.setImage(UIImage(named: hImageName), forState: UIControlState.Highlighted)
        
        btn.sizeToFit()
        
        // 添加监听方法
        if actionName != nil {
            btn.addTarget(target, action: Selector(actionName!), forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        self.init(customView: btn)
    }
}
