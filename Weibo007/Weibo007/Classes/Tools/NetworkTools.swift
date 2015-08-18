//
//  NetworkTools.swift
//  Weibo007
//
//  Created by apple on 15/6/25.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import AFNetworking

class NetworkTools: AFHTTPSessionManager {
    
    private static let instance: NetworkTools = {
        // baseURL 要以 `/` 结尾
        let urlString = "https://api.weibo.com/"
        let baseURL = NSURL(string: urlString)!
        
        let tools = NetworkTools(baseURL: baseURL)
        
        // 设置相应的默认反序列化格式
        tools.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json", "text/json", "text/javascript", "text/plain") as! Set<String>
        
        return tools
    }()
    
    /// 全局访问方法
    class func sharedNetworkTools() -> NetworkTools {
        return instance
    }
    
    // MARK: - 发布微博
    ///  发布文本微博
    func postStatus(text: String, image: UIImage?, finished: (error: NSError?)->()) {
        
        var params = accessToken()
        params["status"] = text
        
        var urlString = "2/statuses/"
        
        // 文本微博
        if image == nil {
            urlString += "update.json"
            
            POST(urlString, parameters: params, success: { (_, JSON) -> Void in
                    finished(error: nil)
                }) { (_, error) -> Void in
                    print(error)
                    
                    finished(error: error)
            }
        } else {
            urlString += "upload.json"
            
            POST(urlString, parameters: params, constructingBodyWithBlock: { (formData) -> Void in
                
                    let data = UIImagePNGRepresentation(image!)
                
                    /**
                        1. 文件的二进制数据
                        2. 服务器的字段名，后端接口会提供
                        3. 保存在服务器的文件名，有些服务器可以随便写(接收到请求后，会做后续处理)
                        4. mimeType，告诉服务器文件类型，application/octect-stream
                    */
                    formData.appendPartWithFileData(data, name: "pic", fileName: "hello", mimeType: "application/octect-stream")
                
                }, success: { (_, _) -> Void in
                    finished(error: nil)
                }, failure: { (_, error) -> Void in
                    print(error)
                    
                    finished(error: error)
            })
        }
    }
    
    // MARK: - 加载微博
    ///  加载数据
    /**
        since_id    若指定此参数，则返回ID比since_id大的微博（即比since_id时间晚的微博），默认为0
        max_id      若指定此参数，则返回ID小于或等于max_id的微博，默认为0
    */
    /// 正在加载数据标记
    private var isLoadingData = false
    
    func loadStatus(since_id: Int, max_id: Int, finished: (array: [[String: AnyObject]]?, error: NSError?) -> ()) {
        
        // 判断是否正在加载数据
        if isLoadingData {
            print("正在加载数据...")
            return
        }
        
        var params = accessToken()
        
        if since_id > 0 {
            params["since_id"] = "\(since_id)"
        }
        
        if max_id > 0 {
            params["since_id"] = "0"
            params["max_id"] = "\(max_id - 1)"
        }
        
        isLoadingData = true
        // 发起网络请求，异步加载数据
        GET("2/statuses/home_timeline.json", parameters: params, success: { (_, JSON) -> Void in
            
                self.isLoadingData = false
                
                // 从结果中获取微博的数组
                if let array = JSON["statuses"] as? [[String: AnyObject]] {
                    // 直接回调数组
                    finished(array: array, error: nil)
                    
                    return
                }
                // 回调空数据，解析失败或者其他原因
                finished(array: nil, error: nil)
            
            }) { (_, error) -> Void in
                
                self.isLoadingData = false
                
                // 提示 print 一定保留，一旦开发中出现错误，可以及时发现
                print(error)
                // 回调通知错误
                finished(array: nil, error: error)
        }
    }
    
    // MARK: - 私有辅助函数
    ///  生成 accessToken 字典
    private func accessToken() -> [String : String] {
        assert(sharedUserAccount != nil, "必须登录之后才能访问网络")
        
        return ["access_token": sharedUserAccount!.access_token]
    }
}
