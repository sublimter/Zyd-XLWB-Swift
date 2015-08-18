//
//  User.swift
//  Weibo007
//
//  Created by apple on 15/6/30.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class User: NSObject {
    /// 用户UID
    var id: Int = 0
    /// 友好显示名称
    var name: String?
    /// 用户头像地址（中图），50×50像素
    var profile_image_url: String? {
        didSet {
            profileURL = NSURL(string: profile_image_url!)
        }
    }
    /// 头像的 URL
    var profileURL: NSURL?
    
    /// 是否是微博认证用户，即加V用户，true：是，false：否
    var verified: Bool = false
    /// 认证类型 -1：没有认证，0，认证用户，2,3,5: 企业认证，220: 达人
    var verified_type: Int = -1
    /// 认证图标
    var verifiedImage: UIImage? {
        switch verified_type {
        case 0:
            // swift中的 switch 不需要 break
            // named 实例化的图像，系统会缓存，内存占用不会高，而且性能好！
            return UIImage(named: "avatar_vip")
        case 2,3,5:
            return UIImage(named: "avatar_enterprise_vip")
        case 220:
            return UIImage(named: "avatar_grassroot")
        default:
            return nil
        }
    }
    
    /// 会员等级
    var mbrank: Int = 0
    /// 会员图片
    var mbImage: UIImage? {
        if mbrank > 0 && mbrank < 7 {
            return UIImage(named: "common_icon_membership_level\(mbrank)")
        }
        return nil
    }
    
    ///  字典转模型函数
    init(dict: [String: AnyObject]) {
        super.init()
        
        setValuesForKeysWithDictionary(dict)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
        
    }
    
    static let properties = ["id", "name", "profile_image_url", "verified", "verified_type", "mbrank"]
    override var description: String {
        let dict = dictionaryWithValuesForKeys(User.properties)
        
        return "\(dict)"
    }
}
