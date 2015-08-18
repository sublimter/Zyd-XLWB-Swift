//
//  NSDate+extension.swift
//  02-日期测试
//
//  Created by apple on 15/7/10.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import Foundation

extension NSDate {
    
    /// 将`新浪微博`的日期字符串转换成日期
    class func sinaDateWithString(string: String) -> NSDate {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM dd HH:mm:ss zzzz yyyy"
        // 指定区域(在真机上尤为重要) 英文 en/中文 cn
        formatter.locale = NSLocale(localeIdentifier: "en")
        
        // 过滤掉时区的日期 - 一旦解析失败，返回当前日期
        return formatter.dateFromString(string) ?? NSDate()
    }
    
    /**
        返回当前日期的描述信息，格式如下：
    
        刚刚(一分钟内)
        X分钟前(一小时内)
        X小时前(当天)
        昨天 HH:mm(昨天)
        MM-dd HH:mm(一年内)
        yyyy-MM-dd HH:mm(更早期)
    */
    func dateDescription() -> String {
        
        // 取出当前的日历 － 提供了大量日期计算函数
        let calendar = NSCalendar.currentCalendar()
        
        if calendar.isDateInToday(self) {
            
            // 计算当前时间和对象日期的秒数差值
            let delta = Int(NSDate().timeIntervalSinceDate(self))

            if delta < 60 {
                return "刚刚"
            } else if delta < 3600 {
                return String(delta / 60) + " 分钟前"
            } else {
                return String(delta / 3600) + " 小时前"
            }
        }
        
        // 日期格式字符串
        var fmtString = "HH:mm"
        if calendar.isDateInYesterday(self) {
            fmtString = "昨天 " + fmtString
        } else {
            
            fmtString = "MM-dd " + fmtString
            
            // print(calendar.component(NSCalendarUnit.Year, fromDate: self))
            // 计算两个日期之间的实际`年度差`
            let components = calendar.components(NSCalendarUnit.Year, fromDate: self, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))
            
            if components.year != 0 {
                fmtString = "yyyy-" + fmtString
            }
        }
        
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en")
        formatter.dateFormat = fmtString
        
        return formatter.stringFromDate(self)
    }
}