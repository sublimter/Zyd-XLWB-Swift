//
//  AppDelegate.swift
//  Weibo007
//
//  Created by apple on 15/6/23.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import AFNetworking

/// 全局变量记录用户账号
var sharedUserAccount = UserAccount.loadAccount()
/// 切换根控制器的通知
let HMSwitchRootVCNotification = "HMSwitchRootVCNotification"

/// @UIApplicationMain 是表示程序的入口，swift 中没有 main.m
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // 打印归档保存的用户信息
        print(sharedUserAccount)
        
        // 设置外观
        setupAppearance()
        // 设置网络
        setupNetwork()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = defaultViewController()
        
        window?.makeKeyAndVisible()
        
        // 注册通知
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchViewController:", name: HMSwitchRootVCNotification, object: nil)
        
        return true
    }
    
    deinit {
        // 注销通知
        NSNotificationCenter.defaultCenter().removeObserver(self, name: HMSwitchRootVCNotification, object: nil)
    }
    
    ///  切换控制器
    func switchViewController(n: NSNotification) {
        // 判断 object 是否为 true，如果是，显示 MainViewController
        let isMainVC = n.object as! Bool
        
        window?.rootViewController = isMainVC ? MainViewController() : WelcomeViewController()
    }
    
    ///  判断加载的默认控制器
    private func defaultViewController() -> UIViewController {
        
        // 1. 判断用户是否登录
        if sharedUserAccount != nil {
            
            // 2. 如果登录，判断是否有新版本
            return isNewUpdate() ? NewFeatureViewController() : WelcomeViewController()
        }
        
        return MainViewController()
    }
    
    /// 是否新版本
    private func isNewUpdate() -> Bool {
        
        // 1. 获取应用程序`当前版本`
        let currentVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        let version = Double(currentVersion)!
        
        // 2. 获取应用程序`之前的版本`，从用户偏好中读取
        let versionKey = "versionKey"
        let sandBoxVersion = NSUserDefaults.standardUserDefaults().doubleForKey(versionKey)
        
        // 3. 将`当前版本`写入用户偏好
        NSUserDefaults.standardUserDefaults().setDouble(version, forKey: versionKey)
        
        return version > sandBoxVersion
    }
    
    /// 设置网络
    private func setupNetwork() {
        // 设置网路指示器
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        // 设置网络缓存
        let urlCache = NSURLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024, diskPath: nil)
        NSURLCache.setSharedURLCache(urlCache)
    }
    
    /// 设置外观
    private func setupAppearance() {
        // 设置外观，一经设置全局有效，必须早，通常会看到 appDelegate 中存在设置外观的代码
        UINavigationBar.appearance().tintColor = UIColor.orangeColor()
        UITabBar.appearance().tintColor = UIColor.orangeColor()
    }
}

