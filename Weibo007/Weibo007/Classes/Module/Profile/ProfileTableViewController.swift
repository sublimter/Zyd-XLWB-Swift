//
//  ProfileTableViewController.swift
//  Weibo007
//
//  Created by apple on 15/6/23.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class ProfileTableViewController: BaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        visitorView?.setupViewInfo("visitordiscover_image_profile", message: "登录后，你的微博、相册、个人资料会显示在这里，展示给别人", isHome: false)
    }
}
