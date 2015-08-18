//
//  WelcomeViewController.swift
//  Weibo007
//
//  Created by apple on 15/6/26.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置头像
        if let urlString = sharedUserAccount?.avatar_large {
            iconView.sd_setImageWithURL(NSURL(string: urlString)!)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        bottomConstraint?.constant = -(UIScreen.mainScreen().bounds.height - 200)
        
        UIView.animateWithDuration(1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            
            }) { _ in
                
                UIView.animateWithDuration(1.0, animations: {
                    self.messageLabel.alpha = 1.0
                    }, completion: { _ in
                        // object = true 表示显示 MainViewController
                        NSNotificationCenter.defaultCenter().postNotificationName(HMSwitchRootVCNotification, object: true)
                })
        }
    }

    /// 头像的底部约束
    var bottomConstraint: NSLayoutConstraint?
    
    // MARK: - 设置界面控件
    override func loadView() {
        view = UIView()
        
        let backImageView = UIImageView(image: UIImage(named: "ad_background"))
        view.addSubview(backImageView)
        view.addSubview(iconView)
        view.addSubview(messageLabel)
        
        // 设置自动布局
        backImageView.ff_Fill(view)
        
        // 记录 iconView 上添加的约束数组
        let cons = iconView.ff_AlignInner(ff_AlignType.BottomCenter, referView: view, size: CGSize(width: 90, height: 90), offset: CGPoint(x: 0, y: -160))
        // 在 cons 数组中查找 iconView 的底部约束
        bottomConstraint = iconView.ff_Constraint(cons, attribute: NSLayoutAttribute.Bottom)
        
        messageLabel.ff_AlignVertical(ff_AlignType.BottomCenter, referView: iconView, size: nil, offset: CGPoint(x: 0, y: 8))
    }
    
    lazy var iconView: UIImageView = {
       
        let iv = UIImageView(image: UIImage(named: "avatar_default_big"))
        
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 45
        
        return iv
    }()
    
    lazy var messageLabel: UILabel = {
       
        let label = UILabel()
        label.text = "欢迎归来"
        label.sizeToFit()
        
        label.alpha = 0
        
        return label
    }()
    
}
