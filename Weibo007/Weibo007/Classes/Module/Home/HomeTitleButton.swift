//
//  HomeTitleButton.swift
//  Weibo007
//
//  Created by apple on 15/6/26.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class HomeTitleButton: UIButton {

    class func button(title: String) -> HomeTitleButton {
        
        let btn = HomeTitleButton()
        
        btn.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(17.0)
        btn.setTitle(title + " ", forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "navigationbar_arrow_down"), forState: UIControlState.Normal)
        btn.sizeToFit()
        
        return btn
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // swift 中，能够直接修改 frame 内部数值
        titleLabel!.frame.origin.x = 0
        imageView!.frame.origin.x = titleLabel!.bounds.width
    }
}
