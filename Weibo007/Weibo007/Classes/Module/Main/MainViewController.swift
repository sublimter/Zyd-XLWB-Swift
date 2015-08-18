//
//  MainViewController.swift
//  Weibo007
//
//  Created by apple on 15/6/23.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        addChildViewControllers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let w = tabBar.bounds.width / CGFloat(5)
        let rect = CGRectMake(0, 0, w, tabBar.bounds.height)
        composeButton.frame = CGRectOffset(rect, 2 * w, 0)
    }
    
    ///  点击撰写按钮，按钮监听方法不能私有
    func composedButtonClicked() {
        let nav = UINavigationController(rootViewController: ComposeViewController())
        
        presentViewController(nav, animated: true, completion: nil)
    }
    
    /// 添加所有的子控制器
    private func addChildViewControllers() {
        addChildViewController(HomeTableViewController(), title: "首页", imageName: "tabbar_home")
        addChildViewController(MessageTableViewController(), title: "消息", imageName: "tabbar_message_center")
        addChildViewController(UIViewController(), title: "", imageName: nil)
        addChildViewController(DiscoverTableViewController(), title: "发现", imageName: "tabbar_discover")
        addChildViewController(ProfileTableViewController(), title: "我", imageName: "tabbar_profile")
    }
    
    ///  添加控制器
    ///
    ///  * vc:        子控制器
    ///  * title:     标题
    ///  * imageName: 图片名称
    private func addChildViewController(vc: UIViewController, title: String, imageName: String?) {

        // 从内向外设置，nav & tabbar 都有标题
        vc.title = title
        
        if imageName != nil {
            vc.tabBarItem.image = UIImage(named: imageName!)
            vc.tabBarItem.selectedImage = UIImage(named: imageName! + "_highlighted")
        }
        
        let nav = UINavigationController(rootViewController: vc)
        
        addChildViewController(nav)
    }
    
    /// 撰写按钮
    private lazy var composeButton: UIButton = {
        
        let btn = UIButton()
        
        btn.setImage(UIImage(named: "tabbar_compose_icon_add"), forState: UIControlState.Normal)
        btn.setImage(UIImage(named: "tabbar_compose_icon_add_highlighted"), forState: UIControlState.Highlighted)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "tabbar_compose_button_highlighted"), forState: UIControlState.Highlighted)
        
        // self. 闭包，提前准备好的代码，在需要的时候执行
        self.tabBar.addSubview(btn)
        
        // 按钮监听方法
        btn.addTarget(self, action: "composedButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
}
