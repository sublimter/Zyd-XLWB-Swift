//
//  OAuthViewController.swift
//  Weibo007
//
//  Created by apple on 15/6/25.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import SVProgressHUD
import AFNetworking

class OAuthViewController: UIViewController, UIWebViewDelegate {
    
    // 0. 定义常量
    private let WB_Client_ID        = "1598433516"
    private let WB_Redirect_URI     = "https://www.baidu.com"
    private let WB_App_Secret       = "d4964e76b75a1f1de00d37a6ffbec8ec"
    
    // 1. webView 加载授权页面
    lazy var webView: UIWebView? = {
        let v = UIWebView()
        v.delegate = self
        
        return v
    }()
    
    override func loadView() {
        // 根视图就是 webView
        view = webView
        
        // 设置 nav 的信息
        title = "新浪微博"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: UIBarButtonItemStyle.Plain, target: self, action: "close")
    }
    
    ///  关闭当前窗口
    func close() {
        SVProgressHUD.dismiss()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 加载授权页面
        loadOAuthPage()
    }
    
    /// 加载授权页面
    private func loadOAuthPage() {
        
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(WB_Client_ID)&redirect_uri=\(WB_Redirect_URI)"
        // ! 表示一定能够生成
        let url = NSURL(string: urlString)!
        
        webView?.loadRequest(NSURLRequest(URL: url))
    }
    
    // MARK: - UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // 0. URL的完整字符串
        let urlString = request.URL!.absoluteString
        
        // 1> 如果不是回调的 URL，就继续加载
        if !urlString.hasPrefix(WB_Redirect_URI) {
            return true
        }
        
        // 2> 如果是回调地址，需要根据 URL 中的内容，判断是否有授权码
        // 获取请求 URL 中的 查询字符串
        let query = request.URL!.query!
        let codeStr = "code="
        
        // 判读是否包含 code=
        if query.hasPrefix(codeStr) {
            let code = query.substringFromIndex(advance(codeStr.endIndex, 0))
            print("获取授权码 \(code)")
            
            loadAccessToken(code)
        } else {
            print("取消授权")
            // 关闭窗口
            close()
        }
        
        return false
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    ///  使用授权码加载 token
    private func loadAccessToken(code: String) {
        // 1. urlString SSL 1.2
        let urlString = "oauth2/access_token"
        
        // 2. 请求参数
        let params = ["client_id": WB_Client_ID,
            "client_secret": WB_App_Secret,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": WB_Redirect_URI]
        
        // 3. 发起网络请求
        NetworkTools.sharedNetworkTools().POST(urlString, parameters: params, success: { (_, JSON) -> Void in
            
            // 字典转模型 －> 加载用户信息，链式调用 Alamofire
            UserAccount(dict: JSON as! [String : AnyObject]).loadUserInfo { (account, error) -> () in
                
                // 判断账户信息是否正确
                if account != nil {
                    print(account)
                    // 1. 设置全局的 account
                    sharedUserAccount = account
                    
                    // 2. 发送通知
                    // object = false 表示显示 WelcomeViewController
                    NSNotificationCenter.defaultCenter().postNotificationName(HMSwitchRootVCNotification, object: false)
                    
                    // 3. 关闭当前控制器
                    self.close()
                    
                    return
                }
                
                print(error)
                SVProgressHUD.showInfoWithStatus("您的网络不给力")
            }
            
            }) { (_, error) -> Void in
                print(error)
                SVProgressHUD.showInfoWithStatus("您的网络不给力")
        }
    }
    
    // dealloc
    deinit {
        print("---------------> 88")
    }
}
