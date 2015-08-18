//
//  BaseTableViewController.swift
//  Weibo007
//
//  Created by apple on 15/6/23.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController, VisitorLoginViewDelegate {

    /// 用户登录标记
    var userLogon = sharedUserAccount != nil
    /// 访客视图
    var visitorView: VisitorLoginView?
    
    override func loadView() {
        
        print("用户登录 \(userLogon)")
        
        userLogon ? super.loadView() : setupVistorView()
    }
    
    ///  创建访客视图
    private func setupVistorView() {
        // 替换根视图
        visitorView = VisitorLoginView()
        // 设置代理
        visitorView?.delegate = self
        view = visitorView!
        
        // 添加导航栏按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: UIBarButtonItemStyle.Plain, target: self, action: "visitorRegisterButtonClicked")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: UIBarButtonItemStyle.Plain, target: self, action: "visitorLoginButtonClicked")
    }
    
    // MARK: - 访客视图协议方法
    func visitorRegisterButtonClicked() {
        print("注册")
    }
    
    func visitorLoginButtonClicked() {
        let vc = OAuthViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        // 对于独立的视图控制器，可以使用 modal 展现
        presentViewController(nav, animated: true, completion: nil)
    }
}
