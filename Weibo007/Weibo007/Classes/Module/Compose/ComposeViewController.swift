//
//  ComposeViewController.swift
//  Weibo007
//
//  Created by apple on 15/7/6.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import SVProgressHUD

/// 微博文字的最大长度
private let statusMaxLength = 140

class ComposeViewController: UIViewController, UITextViewDelegate {

    /// 表情键盘控制器
    private lazy var emoticonKeyboardVC: EmoticonViewController = EmoticonViewController { [unowned self] (emoticon)  in
        self.textView.insertEmoticon(emoticon)
    }
    
    /// 照片选择控制器
    private lazy var photoSelectorVC: PhotoSelectorViewController = PhotoSelectorViewController()
    /// 照片选择器视图
    private lazy var photoSelectorView: UIView = self.photoSelectorVC.view
    /// 照片选择器视图高度约束
    private var photoSelectorViewHeightCons: NSLayoutConstraint?
    
    ///  切换表情视图
    func inputEmoticon() {
        // 如果输入视图是 nil，说明使用的是系统键盘
        print(textView.inputView)
        
        // 要切换键盘之前，需要先关闭键盘
        textView.resignFirstResponder()
        
        // 更换键盘输入视图
        textView.inputView = (textView.inputView == nil) ? emoticonKeyboardVC.view : nil
        
        // 重新设置焦点
        textView.becomeFirstResponder()
    }
    
    ///  选择照片
    func selectPicture() {
        // 照片选择器占屏幕 1/3
        photoSelectorViewHeightCons?.constant = view.bounds.height / 3
        
        // 关闭键盘
        textView.resignFirstResponder()
        
        // 调整 toolBar 的约束
        toolBarBottomCons?.constant = 0
    }
    
    ///  关闭
    func close() {
        textView.resignFirstResponder()
        
        SVProgressHUD.dismiss()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    ///  发布微博
    func sendStatus() {
        // 判断是否有内容
        if textView.emoticonText().characters.count <= 0 {
            return
        }
        
        // 判断文本内容是否够长
        if textView.emoticonText().characters.count > statusMaxLength {
            SVProgressHUD.showInfoWithStatus("文本内容过长!", maskType: SVProgressHUDMaskType.Black)
            return
        }
        
        SVProgressHUD.show()
        // 取数组的最后一张图片，新浪微博给的接口，仅允许上传一张图片
        let image = photoSelectorVC.photos.last
        
        NetworkTools.sharedNetworkTools().postStatus(textView.emoticonText(), image: image) { (error) -> () in
            
            if error != nil {
                SVProgressHUD.showInfoWithStatus("您的网络不给力")
                return
            }
            
            // 发布成功关闭窗口
            self.close()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 注册键盘监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardChanged:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        // 注销通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /// 本地键盘切换标记 - 以下函数专用
    private var localKeyboardFlag = false
    ///  键盘通知变化处理函数
    func keyboardChanged(notification: NSNotification) {
        
        print(notification)
        
        // 1. 拿到 userInfo 中的 endUser Rect
        // oc 中结构体保存在字典中，保存的类型是 NSValue，swift中同样
        let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue
        // 键盘动画时长
        var duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        // 取 UIKeyboardIsLocalUserInfoKey，如果为0，不做动画
        let local = notification.userInfo!["UIKeyboardIsLocalUserInfoKey"]!.boolValue
        
        if !local {
            localKeyboardFlag = true
            return
        }
        
        // 根据 localKeyboardFlag 设置动画时长
        duration = localKeyboardFlag ? 0 : duration
        localKeyboardFlag = false
        
        // 2. 设置键盘高度
        toolBarBottomCons?.constant = -(view.bounds.height - rect.origin.y)
        
        // 3. 动画
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    ///  `第一次`进入界面激活文本焦点
    private var isFirstLoad = true
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstLoad {
            textView.becomeFirstResponder()
            isFirstLoad = false
        }
    }
  
    // 键盘会上下移动
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        textView.resignFirstResponder()
//    }
    
    // MARK: - textView delegate
    func textViewDidChange(textView: UITextView) {
        // 根据 textView 是否有文本，判断是否隐藏控件
        placeHolderLabel.hidden = textView.hasText()
        navigationItem.rightBarButtonItem?.enabled = textView.hasText()
        
        // 判断文字长度
        let len = statusMaxLength - textView.emoticonText().characters.count
        
        lengthLabel.text = (len == 0) ? "" : String(len)
        lengthLabel.textColor = len > 0 ? UIColor.lightGrayColor() : UIColor.redColor()
    }
    
    // MARK: - 准备 UI
    override func loadView() {
        view = UIView()
        
        view.backgroundColor = UIColor.whiteColor()
        
        // 1. 添加子控制器
        addChildViewController(emoticonKeyboardVC)
        addChildViewController(photoSelectorVC)
        view.addSubview(photoSelectorView)
        
        prepareUI()
    }
    
    ///  准备 UI
    private func prepareUI() {
        // 取消自动调整滚动视图缩紧
        automaticallyAdjustsScrollViewInsets = false
        
        prepareNavigationBar()
        prepareToolBar()
        prepareTextView()
        prepreaOthers()
    }
    
    ///  准备其他控件
    private func prepreaOthers() {
        view.addSubview(lengthLabel)
        
        lengthLabel.text = "-10"
        lengthLabel.ff_AlignInner(ff_AlignType.BottomRight, referView: textView, size: nil, offset: CGPoint(x: -12, y: -12))
        
        // 设置照片选择器的布局
        photoSelectorView.ff_AlignVertical(ff_AlignType.TopCenter, referView: toolBar, size: nil)
        // 指定宽度和高度
        view.addConstraint(NSLayoutConstraint(item: photoSelectorView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0))
        photoSelectorViewHeightCons = NSLayoutConstraint(item: photoSelectorView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 0)
        view.addConstraint(photoSelectorViewHeightCons!)
    }
    
    private func prepareToolBar() {

        // 提示：设置一个和按钮背景一样的颜色，具体的数值，`平面设计师`会告诉我们
        toolBar.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
        
        let itemSettings = [["imageName": "compose_toolbar_picture", "action": "selectPicture"],
            ["imageName": "compose_mentionbutton_background"],
            ["imageName": "compose_trendbutton_background"],
            ["imageName": "compose_emoticonbutton_background", "action": "inputEmoticon"],
            ["imageName": "compose_addbutton_background"]]
        
        // 所有按钮的数组
        var items = [UIBarButtonItem]()
        
        // 设置按钮 - 问题：图片名称(高亮图片) / 监听方法
        for settings in itemSettings {
            items.append(UIBarButtonItem(imageName: settings["imageName"]!, highlightedImageName: nil, target: nil, actionName: settings["action"]))
            
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        // 删除末尾的弹簧
        items.removeLast()
        
        toolBar.items = items
        
        // 添加 toolBar
        view.addSubview(toolBar)
        let cons = toolBar.ff_AlignInner(ff_AlignType.BottomLeft, referView: view, size: nil)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["toolBar" : toolBar]))
        
        // 记录工具栏底部约束
        toolBarBottomCons = toolBar.ff_Constraint(cons, attribute: NSLayoutAttribute.Bottom)
    }
    
    private func prepareTextView() {
        view.addSubview(textView)
        
        textView.font = UIFont.systemFontOfSize(18)
        // 手动设置间距
        textView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        textView.ff_AlignInner(ff_AlignType.TopLeft, referView: view, size: nil)
        // 没有穿透效果的解决方法
        // textView.ff_AlignInner(ff_AlignType.TopLeft, referView: view, size: nil, offset: CGPoint(x: 0, y: 64))
        textView.ff_AlignVertical(ff_AlignType.TopRight, referView: photoSelectorView, size: nil)
        
        textView.delegate = self
        
        // 设置垂直滚动
        textView.alwaysBounceVertical = true
        // 滚动关闭键盘
        textView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        
        // 设置 占位标签
        placeHolderLabel.text = "分享新鲜事..."
        placeHolderLabel.sizeToFit()
        textView.addSubview(placeHolderLabel)
        placeHolderLabel.ff_AlignInner(ff_AlignType.TopLeft, referView: textView, size: nil, offset: CGPoint(x: 5, y: 8))
    }
    
    private func prepareNavigationBar() {
        // 1. 左侧按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Plain, target: self, action: "close")
        
        // 2. 右侧按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "发送", style: UIBarButtonItemStyle.Plain, target: self, action: "sendStatus")
        navigationItem.rightBarButtonItem?.enabled = false
        
        // 3. 导航栏
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 32))
        let label1 = UILabel(color: UIColor.darkGrayColor(), fontSize: 15)
        label1.text = "发微博"
        label1.sizeToFit()
        let label2 = UILabel(color: UIColor(white: 0.0, alpha: 0.5), fontSize: 13)
        label2.text = sharedUserAccount?.name ?? ""
        label2.sizeToFit()
        
        titleView.addSubview(label1)
        titleView.addSubview(label2)
        
        label1.ff_AlignInner(ff_AlignType.TopCenter, referView: titleView, size: nil)
        label2.ff_AlignInner(ff_AlignType.BottomCenter, referView: titleView, size: nil)
        
        navigationItem.titleView = titleView
    }
    
    // MARK: 懒加载
    /// 工具栏底部约束
    private var toolBarBottomCons: NSLayoutConstraint?
    private lazy var textView = UITextView()
    private lazy var toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
    private lazy var placeHolderLabel = UILabel(color: UIColor.lightGrayColor(), fontSize: 18)
    private lazy var lengthLabel = UILabel(color: UIColor.redColor(), fontSize: 12)
    
}
