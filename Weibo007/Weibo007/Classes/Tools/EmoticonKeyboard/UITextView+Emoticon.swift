//
//  UITextView+Emoticon.swift
//  01-表情处理
//
//  Created by apple on 15/7/7.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

extension UITextView {
    
    ///  向 textView 插入表情符号
    func insertEmoticon(emoticon: Emoticon) {
        
        // 0. 删除按钮判断 - remove/delete
        if emoticon.removeButton {
            deleteBackward()
            
            return
        }
        
        // 1. emoji - 会触发 textViewDidChange 方法
        if emoticon.emoji != nil {
            replaceRange(selectedTextRange!, withText: emoticon.emoji ?? "")
        }
        
        // 2. 表情符号
        if emoticon.chs != nil {
            // 1. 生成一个属性文本，字体已经设置
            let imageText = EmoticonAttachment.emoticonString(emoticon, font: font!)
            
            // 2. 获得文本框完整的属性文本
            let strM = NSMutableAttributedString(attributedString: attributedText)
            
            strM.replaceCharactersInRange(selectedRange, withAttributedString: imageText)
            
            // 3. 将属性文本，重新设置给 textView
            // 3.1 记录光标位置
            let range = selectedRange
            // 3.2 设置文本
            attributedText = strM
            // 3.3 恢复光标位置
            selectedRange = NSMakeRange(range.location + 1, 0)
            
            // 4. 主动触发代理方法
            delegate?.textViewDidChange!(self)
        }
    }
    
    ///  返回 textView 完整的表情字符串
    func emoticonText() -> String {
        
        // 定义结果字符串
        var strM = String()
        
        // 遍历内部细节
        attributedText.enumerateAttributesInRange(NSMakeRange(0, attributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (dict, range, _) -> Void in
            
            // 如果字典中包含 NSAttachment key 就说明是图片
            // 新问题：如何从 `NSAttachment` 中获取到 表情的文本？ - 继承一个子类，专门记录表情
            if let attachment = dict["NSAttachment"] as? EmoticonAttachment {
                strM += attachment.chs ?? ""
            } else {    // 否则就是文字，利用range提取内容，拼接字符串即可
                let str = (self.attributedText.string as NSString).substringWithRange(range)
                strM += str
            }
        }
        
        return strM
    }
}
