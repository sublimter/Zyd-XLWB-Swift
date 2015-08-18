//
//  String+Regex.swift
//  01-正则表达式
//
//  Created by apple on 15/7/9.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import Foundation

extension String {
    
    ///  提取字符串中第一个 href 链接
    func hrefLink() -> (link: String, text: String)? {
        let pattern = "<a.*?\"(.*?)\".*?>(.*?)</a>"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators)
            
            // 开始匹配
            let result = regex.firstMatchInString(self, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: self.characters.count))
            
            // 判断是否找到匹配项
            if result != nil {
                
                let r1 = result!.rangeAtIndex(1)
                let r2 = result!.rangeAtIndex(2)
                
                let link = (self as NSString).substringWithRange(r1)
                let text = (self as NSString).substringWithRange(r2)
                
                return(link, text)
            }
            return nil
        } catch {
            print(error)
            
            return nil
        }
    }
}