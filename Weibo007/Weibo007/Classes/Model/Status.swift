//
//  Status.swift
//  Weibo007
//
//  Created by apple on 15/6/30.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import SDWebImage

// TODO: - 要删除
/// 访问微博首页 URL
private let WB_Home_Timeline_URL = "2/statuses/home_timeline.json"

class Status: NSObject {

    // MARK: - 数据模型属性
    /// 微博创建时间
    var created_at: String?
    /// 微博ID
    var id: Int = 0
    /// 微博信息内容
    var text: String?
    /// 微博来源
    var source: String? {
        didSet {
            if let result = source?.hrefLink() {
                source = result.text
            }
        }
    }
    /// 配图数组
    var pic_urls: [[String: String]]? {
        didSet {
            // 设置图像 URL 的数组
            imageURLs = [NSURL]()
            largeImageURLs = [NSURL]()
            
            // 生成并且添加 url
            for dict in pic_urls! {
                var urlString = dict["thumbnail_pic"]!
                
                // 缩略图 URL
                imageURLs?.append(NSURL(string: urlString)!)
                
                urlString = urlString.stringByReplacingOccurrencesOfString("thumbnail", withString: "large")
                // 大图 URL
                largeImageURLs?.append(NSURL(string: urlString)!)
            }
        }
    }
    /// 配图的 URL 数组
    private var imageURLs: [NSURL]?
    /// 计算型属性，配图的 URL 数组
    /// 如果是转发微博，只需要缓存转发微博的 imageURLs，原创的 imageURLs 是 nil
    /// 如果是原创微博，imageURLs 可能有内容
    var picURLs: [NSURL]? {
        return retweeted_status != nil ? retweeted_status?.imageURLs : imageURLs
    }
    /// 大图的 URL 数组
    private var largeImageURLs: [NSURL]?
    var largePicURLs: [NSURL]? {
        return retweeted_status != nil ? retweeted_status?.largeImageURLs : largeImageURLs
    }
    
    /// 用户模型
    var user: User?
    /// 被转发的原微博信息字段，当该微博为转发微博时返回
    var retweeted_status: Status?
    
    /// 类属性数组
    static let properties = ["created_at", "id", "text", "source", "pic_urls", "user", "retweeted_status"]
    
    ///  字典转模型函数
    ///  1. swift 中 kvc 的效率非常差，不建议使用字典转模型工具
    ///  2. 如果过分依赖字典转模型工具，会忽略模型的作用！
    init(dict: [String: AnyObject]) {
        super.init()

        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forKey key: String) {
        if key == "user" {
            if let userDict = value as? [String: AnyObject] {
                // 给 user 属性设置数值
                user = User(dict: userDict)
            }

            return
        }
        
        if key == "retweeted_status" {
            if let retweetedDict = value as? [String: AnyObject] {
                retweeted_status = Status(dict: retweetedDict)
            }

            return
        }
        
        super.setValue(value, forKey: key)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    override var description: String {
        let dict = dictionaryWithValuesForKeys(Status.properties)
        
        return "\(dict)"
    }
    
    ///  加载数据
    /**
        since_id    若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0
        max_id      若指定此参数，则返回ID小于或等于max_id的微博，默认为0
    */
    /// 正在加载数据标记
    private static var isLoadingData = false
    
    class func loadStatus(since_id: Int, max_id: Int, finished: (statuses: [Status]?, error: NSError?) -> ()) {
        
        // 发起网络请求
        NetworkTools.sharedNetworkTools().loadStatus(since_id, max_id: max_id) { (array, error) -> () in
            
            if error != nil {
                finished(statuses: nil, error: error)
                return
            }
            
            if array == nil {
                finished(statuses: nil, error: nil)
                return
            }
            
            // 1. 获得微博的模型数组
            let list = statuses(array!)
            
            // 2. 异步缓存微博数组中的所有图像
            cacheWebImages(list, finished: finished)
        }
    }
    
    /// 缓存微博数组中的所有图像
    /// 缓存完所有图像之后，再通知调用方更新界面！
    /**
        要解决的问题：所有图片`被缓存完成`后，统一回调
        知识点：dispatch_group_enter
    
        提示：暂时不适合抽取，如果要抽取，应该如何做？
        可以单独提供一个函数，能够获取所有的 URL 的数组！
    */
    private class func cacheWebImages(list: [Status], finished: (statuses: [Status]?, error: NSError?) -> ()) {
        
        // 0. 定义调度组
        let group = dispatch_group_create()
        
        // 1. 遍历数组
        for s in list {
            // 2. 判断 picURLs 是否有内容
            if s.picURLs == nil || s.picURLs!.isEmpty {
                continue
            }
            
            // 2. 进一步遍历 picURLs 的数组，缓存数组中的图片
            for url in s.picURLs! {
                // 1> 进入组，后续的 block 代码会受 group 监听
                dispatch_group_enter(group)
                
                // 用 sdwebimage 缓存图片 downloadImageWithURL 是 SDWebImage 核心的图像下载函数
                SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil, completed: { (_, _, _, _, _)  in
                    
                    // 代码执行到此，说明图片已经被缓存完成
                    // 2> 离开组
                    dispatch_group_leave(group)
                })
            }
        }
        
        // 3> 监听群组调度执行
        dispatch_group_notify(group, dispatch_get_main_queue()) {
            // 完成回调
            finished(statuses: list, error: nil)
        }
    }
    
    /// 使用传入的数组，完成网络模型转 Status 数组
    private class func statuses(array: [[String: AnyObject]]) -> [Status] {
        
        // 定义可变数组
        var arrayM = [Status]()
        
        // 遍历 array
        for dict in array {
            arrayM.append(Status(dict: dict))
        }
        
        return arrayM
    }
}
