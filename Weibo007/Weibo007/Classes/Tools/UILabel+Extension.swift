//
//  UILabel+Extension.swift
//  Weibo007
//
//  Created by apple on 15/6/30.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

extension UILabel {
    
    convenience init(color: UIColor, fontSize: CGFloat, mutiLines: Bool = false) {
        self.init()

        font = UIFont.systemFontOfSize(fontSize)
        textColor = color
        
        if mutiLines {
            numberOfLines = 0
        }
    }
}
