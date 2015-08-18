//
//  VisitorLoginView.swift
//  Weibo007
//
//  Created by apple on 15/6/23.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

/// 访客视图协议 - 协议需要继承自 NSObjectProtocol
protocol VisitorLoginViewDelegate: NSObjectProtocol {
    func visitorRegisterButtonClicked()
    func visitorLoginButtonClicked()
}

class VisitorLoginView: UIView {

    ///  代理 weak id<VisitorLoginViewDelegate> delegate
    weak var delegate: VisitorLoginViewDelegate?
    
    ///  设置视图内容
    ///
    ///  :param: iconName 图标名称
    ///  :param: message  消息文本
    ///  :param: isHome   是否首页
    func setupViewInfo(iconName: String, message: String, isHome: Bool) {
        messageLabel.text = message
        
        if isHome {
            homeIconView.hidden = false
            iconView.image = UIImage(named: "visitordiscover_feed_image_smallicon")
        } else {
            homeIconView.hidden = true
            iconView.image = UIImage(named: iconName)
            // 将视图层次置后
            sendSubviewToBack(maskIconView)
        }
    }
    
    ///  启动动画
    func startAnmiation() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue = 2 * M_PI
        anim.duration = 20
        
        anim.repeatCount = MAXFLOAT
        
        iconView.layer.addAnimation(anim, forKey: nil)
    }
    
    /// 用户注册
    func register() {
        delegate?.visitorRegisterButtonClicked()
    }
    
    /// 用户登录
    func login() {
        delegate?.visitorLoginButtonClicked()
    }
    
    // 视图的默认构造方法
    // 创建控件，并且指定布局，用 xib & sb 开发不会调用
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }

    // 解档，用 xib & sb 开发会调用
    required init(coder aDecoder: NSCoder) {
        print(__FUNCTION__)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 创建控件
    private func setupUI() {
        // 1. 添加控件 - 能够看清控件添加的层次关系
        addSubview(iconView)
        addSubview(maskIconView)
        addSubview(homeIconView)
        addSubview(messageLabel)
        addSubview(registerButton)
        addSubview(loginButton)
        
        // 2. 自动布局
        // 任何一个控件，都可以参照另外一个控件准确的设置位置
        iconView.ff_AlignInner(ff_AlignType.CenterCenter, referView: self, size: nil, offset: CGPoint(x: 0, y: -40))
        homeIconView.ff_AlignInner(ff_AlignType.CenterCenter, referView: iconView, size: nil)
        messageLabel.ff_AlignVertical(ff_AlignType.BottomCenter, referView: iconView, size: CGSize(width: 240, height: 40), offset: CGPoint(x: 0, y: 20))
        registerButton.ff_AlignVertical(ff_AlignType.BottomLeft, referView: messageLabel, size: CGSize(width: 100, height: 40), offset: CGPoint(x: 0, y: 20))
        loginButton.ff_AlignVertical(ff_AlignType.BottomRight, referView: messageLabel, size: CGSize(width: 100, height: 40), offset: CGPoint(x: 0, y: 20))
        
        // 遮罩视图的布局
        maskIconView.ff_Fill(self, insets: UIEdgeInsets(top: 0, left: 0, bottom: 160, right: 0))
        
        // 背景颜色 237.0 / 255.0 `237` 这个数值是美工会告诉我们
        backgroundColor = UIColor(white: 237.0 / 255.0, alpha: 1.0)
    }
    
    // MARK: - 懒加载控件
    /// 图标
    lazy var iconView: UIImageView = {
       
        let image = UIImage(named: "visitordiscover_feed_image_smallicon")
        return UIImageView(image: image)
    }()
    
    /// 遮罩图片，不要写 maskView
    lazy var maskIconView: UIImageView = {
        let image = UIImage(named: "visitordiscover_feed_mask_smallicon")
        return UIImageView(image: image)
    }()
    
    /// 房子
    lazy var homeIconView: UIImageView = {
        
        let image = UIImage(named: "visitordiscover_feed_image_house")
        return UIImageView(image: image)
    }()
    
    /// 文字标签
    lazy var messageLabel: UILabel = {
        
        // 一旦使用了自动布局，frame 就失效了，在添加控件布局时有效
        let label = UILabel(frame: CGRectMake(0, 0, 240, 40))
        label.text = "登录后，最新、最热微博尽在掌握，不再会与实事潮流擦肩而过"
        label.textColor = UIColor.darkGrayColor()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        label.preferredMaxLayoutWidth = 224
        // 最多两行，超出之后...
        label.numberOfLines = 2
        
        label.sizeToFit()
        
        return label
    }()
    
    /// 注册按钮
    lazy var registerButton: UIButton = {
        
        let btn = UIButton(frame: CGRectMake(0, 0, 100, 40))
        
        btn.setTitle("注册", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        
        btn.addTarget(self, action: "register", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    /// 登录按钮
    lazy var loginButton: UIButton = {
        
        let btn = UIButton(frame: CGRectMake(200, 220, 100, 40))
        
        btn.setTitle("登录", forState: UIControlState.Normal)
        btn.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "common_button_white_disable"), forState: UIControlState.Normal)
        
        btn.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
}
