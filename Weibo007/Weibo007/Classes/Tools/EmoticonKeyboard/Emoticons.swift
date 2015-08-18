//
//  Emoticons.swift
//  01-表情处理
//
//  Created by apple on 15/7/7.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

/**
    说明：
    1. Emoticons.bundle 的根目录下存放的 emoticons.plist 保存了 packages 表情包信息
        packages 是一个数组
            字典中的属性 id 对应的分组路径的名称
    2. 在 id 对应的目录下，各自都保存有 info.plist
        group_name_cn   保存的是分组名称
        emoticons       保存的是表情信息数组
            code            UNICODE 编码字符串
            chs             表情文字，发送给新浪微博服务器的文本内容
            png             表情图片，在 App 中进行图文混排使用的图片
*/
/// 表情包
class EmoticonPackage: NSObject {
    /// 表情路径
    var id: String?
    /// 分组名称
    var groupName: String?
    /// 表情数组
    var emoticons: [Emoticon]?
    
    init(id: String) {
        self.id = id
    }
    
    ///  添加喜爱的表情
    func addFavoriteEmoticon(emoticon: Emoticon) {
        
        // 判断数组中是否已经包含该表情
        let contain = emoticons!.contains(emoticon)
        if !contain {
            // 将表情添加到 `最近的` emoticons 数组
            emoticons?.append(emoticon)
        }
        
        // 根据 times 进行数组排序，删除末尾记录
        var result = emoticons!
        // 对数组进行排序
//        result = result.sort({ (e1, e2) -> Bool in
//            e1.times > e2.times
//        })
        // 排序的简写
        result = result.sort { $0.times > $1.times }
        
        if !contain {
            // 删除末尾的表情
            result.removeLast()
        }
        
        // 重新设置表情数组
        emoticons = result
    }
    
    /// 表情包数组 - 只有在第一次使用的时候，会实例化
    static let packagesList = EmoticonPackage.packages()
    
    /// 生成表情属性字符串
    class func emoticonAttributeString(string: String, font: UIFont) -> NSAttributedString? {
        // [] 是正则表达式保留字，在使用时，需要使用转义 \\
        let pattern = "\\[.*?\\]"
        
        do {
            let regex = try  NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators)
            
            let checkResults = regex.matchesInString(string, options: NSMatchingOptions(rawValue: 0), range: NSRange(location: 0, length: string.characters.count))
            
            // 取得结果的计数
            var count = checkResults.count
            
            // 创建可变的属性字符串
            let strM = NSMutableAttributedString(string: string)
            
            // 遍历结果 ...
            while count > 0 {
                // 获取匹配结果
                let result = checkResults[--count]
                
                // 取出 range
                let r = result.rangeAtIndex(0)
                
                // 根据 range 取出子串
                let subStr = (string as NSString).substringWithRange(r)
                
                // 根据 subStr 获得 emoticon 表情符号
                if let emoticon = emotionWithString(subStr) {
                    // 根据 emoticon 获得属性字符串
                    let attrStr = EmoticonAttachment.emoticonString(emoticon, font: font)
                    // 替换文本
                    strM.replaceCharactersInRange(r, withAttributedString: attrStr)
                }
            }
            
            return strM
        } catch {
            print(error)
            
            return nil
        }
    }
    
    ///  查找指定字符串对应的表情
    private class func emotionWithString(string: String) -> Emoticon? {
        // 1. 查找表情符号
        var emoticon: Emoticon?
        
        // 遍历大数组
        for package in EmoticonPackage.packagesList {
            
            emoticon = package.emoticons?.filter { $0.chs == string }.last
            
            if emoticon != nil {
                break
            }
        }
        
        // 2. 返回结果
        return emoticon
    }
    
    ///  加载表情包`数组`
    private class func packages() -> [EmoticonPackage] {
        var list = [EmoticonPackage]()
        
        // 0. 设置最近的表情包
        let p = EmoticonPackage(id: "")
        p.groupName = "最近AA"
        // 追加表情
        p.appendEmptyEmoticons()
        list.append(p)
        
        // 1. 读取 emoticons.plist
        let path = NSBundle.mainBundle().pathForResource("emoticons.plist", ofType: nil, inDirectory: "Emoticons.bundle")!
        let dict = NSDictionary(contentsOfFile: path)!
        let array = dict["packages"] as! [[String: AnyObject]]
        
        // 2. 遍历数组
        for d in array {
            // 根据 id 的内容分别加载表情数组
            let p = EmoticonPackage(id: d["id"] as! String)
            p.loadEmoticons()
            p.appendEmptyEmoticons()
            
            list.append(p)
        }
        
        return list
    }
    
    ///  加载对应的表情数组
    ///  每 20 个按钮，追加一个删除按钮
    private func loadEmoticons() {
        
        // 加载 id 路径对应的 info.plist
        print(plistPath())
        let dict = NSDictionary(contentsOfFile: plistPath())!
        // 设置分组名
        groupName = dict["group_name_cn"] as? String
        let array = dict["emoticons"] as! [[String: String]]
        
        // 实例化表情数组
        emoticons = [Emoticon]()
        
        // 加载表情数组，遍历数组
        var index = 0
        for d in array {
            emoticons?.append(Emoticon(id: id, dict: d))
            
            index++
            if index == 20 {
                // 插入删除按钮
                emoticons?.append(Emoticon(isRemoveButton: true))
                index = 0
            }
        }
    }
    
    ///  追加空白按钮，方便界面布局，如果一个界面的图标不足20个，补足，最后添加一个删除按钮
    private func appendEmptyEmoticons() {
        
        if emoticons == nil {
            emoticons = [Emoticon]()
        }
        
        let count = emoticons!.count % 21
        if count > 0 || emoticons!.count == 0 {
            for _ in count..<20 {
                // 追加空白按钮
                emoticons?.append(Emoticon(isRemoveButton: false))
            }
            // 追加一个删除按钮
            emoticons?.append(Emoticon(isRemoveButton: true))
        }
    }
    
    ///  返回 info.plist 的路径
    private func plistPath() -> String {
        return EmoticonPackage.bundlePath().stringByAppendingPathComponent(id!).stringByAppendingPathComponent("info.plist")
    }
    
    /// 返回表情包路径
    private class func bundlePath() -> String {
        return NSBundle.mainBundle().bundlePath.stringByAppendingPathComponent("Emoticons.bundle")
    }
}

/// 表情模型
class Emoticon: NSObject {
    /// 表情路径
    var id: String?
    /// 表情文字，发送给新浪微博服务器的文本内容
    var chs: String?
    /// 表情图片，在 App 中进行图文混排使用的图片
    var png: String?
    /// 图片的完整路径 - 计算型属性，只读属性
    var imagePath: String? {
        return png == nil ? nil : EmoticonPackage.bundlePath().stringByAppendingPathComponent(id!).stringByAppendingPathComponent(png!)
    }
    
    /// UNICODE 编码字符串
    var code: String? {
        didSet {
            // 1. 扫描器，可以扫描指定字符串中特定的文字
            let scanner = NSScanner(string: code!)
            // 2. 扫描整数 Unsafe`Mutable`Pointer 可变的指针，要修改参数的内存地址的内容
            var result: UInt32 = 0
            scanner.scanHexInt(&result)
            
            // 3. 生成字符串：UNICODE 字符 -> 转换成字符串
            emoji = "\(Character(UnicodeScalar(result)))"
        }
    }
    /// emoji 字符串
    var emoji: String?
    /// 是否删除按钮标记
    var removeButton = false
    /// 用户使用次数
    var times = 0
    
    init(isRemoveButton: Bool) {
        removeButton = isRemoveButton
    }
    
    init(id: String?, dict: [String: String]) {
        super.init()
        
        self.id = id
        
        // 使用 KVC 设置属性之前，必须调用 super.init
        setValuesForKeysWithDictionary(dict)
    }
    
    // 只要重写，就会过滤调用未定义的key - 再使用 setValuesForKeysWithDictionary 就不会崩溃了
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {

    }
}
