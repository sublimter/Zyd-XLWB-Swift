//
//  UIColor+Extension.swift
//  Weibo007
//
//  Created by apple on 15/7/3.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func randomColor() -> UIColor {
        return UIColor(red: randomValue(), green: randomValue(), blue: randomValue(), alpha: 1.0)
    }
    
    private class func randomValue() -> CGFloat {
        return CGFloat(arc4random_uniform(256)) / 255
    }
}