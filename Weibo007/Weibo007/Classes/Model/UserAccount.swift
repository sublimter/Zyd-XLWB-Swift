//
//  UserAccount.swift
//  Weibo007
//
//  Created by apple on 15/6/25.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class UserAccount: NSObject, NSCoding {
    /// 用于调用access_token，接口获取授权后的access token
    var access_token: String
    /// access_token的生命周期，单位是秒数(实际是数值！)
    var expires_in: NSTimeInterval
    
    /// 过期日期
    /// 程序创建人有5年有效期，普通用户有效期三天
    var expiresDate: NSDate
    
    /// 当前授权用户的UID
    var uid: String
    
    /// 友好显示名称
    var name: String?
    /// 用户头像地址（大图），180×180像素
    var avatar_large: String?
    
    init(dict: [String: AnyObject]) {
        access_token = dict["access_token"] as! String
        expires_in = dict["expires_in"] as! NSTimeInterval
        uid = dict["uid"] as! String
        
        // 计算过期日期
        expiresDate = NSDate(timeIntervalSinceNow: expires_in)
    }
    
    ///  加载用户信息
    func loadUserInfo(finished: (account: UserAccount?, error: NSError?) -> ()) {
        
        let params = ["access_token": access_token, "uid": uid]
        
        NetworkTools.sharedNetworkTools().GET("2/users/show.json", parameters: params, success: { (_, JSON) -> Void in
            
            let dict = JSON as! [String: AnyObject]
            self.name = dict["name"] as? String
            self.avatar_large = dict["avatar_large"] as? String
            
            // 目前的用户信息才是完整的
            // 保存用户信息
            self.saveAccount()
            
            // 通知调用方，处理完成
            finished(account: self, error: nil)
            
            }) { (_, error) -> Void in
                finished(account: nil, error: error)
        }
    }
    
    /// 打印对象信息
    override var description: String {
        let properties = ["access_token", "expires_in", "uid", "expiresDate", "avatar_large", "name"]
        
        return "\(self.dictionaryWithValuesForKeys(properties))"
    }
    
    // MARK: - 保存和加载文件
    /// 归档路径，swift中的类常量都是使用 static 来定义的
    static let accountPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).last!.stringByAppendingPathComponent("account.plist")
    
    ///  将当前对象归档保存至沙盒 `Keyed` 键值归档/解档
    func saveAccount() {
        print(UserAccount.accountPath)
        NSKeyedArchiver.archiveRootObject(self, toFile: UserAccount.accountPath)
    }
    
    /// 注意：如果之前没有归档，可能会返回 nil
    class func loadAccount() -> UserAccount? {
        print("加载用账户")
        // 判断 token 是否已经过期，如果过期，直接返回 nil，进入登录界面
        if let account = NSKeyedUnarchiver.unarchiveObjectWithFile(accountPath) as? UserAccount {
            
            // 判断日期是否过期，根当前系统时间进行`比较`，低于当前系统时间，就认为过期
            // 过期日期`大于`当前日期，结果应该是降序
            if account.expiresDate.compare(NSDate()) == NSComparisonResult.OrderedDescending {
                return account
            }
        }
        
        return nil
    }
    
    // MARK: - NSCoding 归档接档使用的 key 保持一致即可
    ///  解档方法，aDecoder 解码器，将保存在磁盘的二进制文件转换成 对象，和反序列化很像
    required init?(coder aDecoder: NSCoder) {
        access_token = aDecoder.decodeObjectForKey("access_token") as! String
        expires_in = aDecoder.decodeDoubleForKey("expires_in")
        expiresDate = aDecoder.decodeObjectForKey("expiresDate") as! NSDate
        uid = aDecoder.decodeObjectForKey("uid") as! String
        
        name = aDecoder.decodeObjectForKey("name") as? String
        avatar_large = aDecoder.decodeObjectForKey("avatar_large") as? String
    }
    
    ///  归档，aCoder 编码器，将对象转换成二进制数据保存到磁盘，和序列化很像
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(access_token, forKey: "access_token")
        aCoder.encodeDouble(expires_in, forKey: "expires_in")
        aCoder.encodeObject(expiresDate, forKey: "expiresDate")
        aCoder.encodeObject(uid, forKey: "uid")
        
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(avatar_large, forKey: "avatar_large")
    }
}
