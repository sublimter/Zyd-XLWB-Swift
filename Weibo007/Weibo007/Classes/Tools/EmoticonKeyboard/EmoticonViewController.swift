//
//  EmoticonViewController.swift
//  01-表情处理
//
//  Created by apple on 15/7/7.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

/// 可重用表示符
private let HMEmoticonKeyboardIdentifier = "HMEmoticonKeyboardIdentifier"

class EmoticonViewController: UIViewController {

    /// 选中表情的回调
    var didSelectedEmoticonCallBack: (emoticon: Emoticon)->()
    
    init(didSelectedEmoticon: (emoticon: Emoticon)->()) {
        // 记录闭包
        didSelectedEmoticonCallBack = didSelectedEmoticon
        
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///  选中表情分组
    func selectItem(item: UIBarButtonItem) {
        let indexPath = NSIndexPath(forItem: 0, inSection: item.tag)
        // 让 collectionView 滚动到对应 section
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.redColor()
        
        prepareUI()
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        print("\(__FUNCTION__) \(collectionView)")
//    }
//    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        
//        print("\(__FUNCTION__) \(collectionView)")
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        print("\(__FUNCTION__) \(collectionView)")
//    }
    
    ///  准备界面
    private func prepareUI() {
        view.addSubview(toolBar)
        view.addSubview(collectionView)
        
        // 自动布局 - 提示：如果要做第三方框架，尽量不要使用其他框架
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var cons = [NSLayoutConstraint]()
        let viewDict = ["collectionView": collectionView, "toolBar": toolBar]
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[toolBar]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict)
        cons += NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[collectionView]-0-[toolBar(44)]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewDict)
        
        // 添加约束
        view.addConstraints(cons)
        
        prepareToolbar()
        prepareCollectionView()
    }
    
    ///  准备 CollectionView
    private func prepareCollectionView() {
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.pagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        // 注册可重用cell
        collectionView.registerClass(EmoticonCell.self, forCellWithReuseIdentifier: HMEmoticonKeyboardIdentifier)
    }
    
    ///  准备工具条
    private func prepareToolbar() {
        toolBar.tintColor = UIColor.darkGrayColor()

        var items = [UIBarButtonItem]()
        
        var index = 0
        for s in packages {
            let item = UIBarButtonItem(title: s.groupName, style: UIBarButtonItemStyle.Plain, target: self, action: "selectItem:")
            item.tag = index++
            
            items.append(item)
            items.append(UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil))
        }
        items.removeLast()
        
        toolBar.items = items
    }
    
    //  MARK: - 控件懒加载
    private lazy var toolBar = UIToolbar()
    private lazy var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: EmoticonLayout())
    
    // MARK: - 定义一个私有的布局类
    private class EmoticonLayout: UICollectionViewFlowLayout {
        
        // 在 collectionView 的大小设置完成之后，准备布局之前会调用一次
        private override func prepareLayout() {
            super.prepareLayout()
            
            print(__FUNCTION__)
            
            let s = collectionView!.bounds.width / 7
            itemSize = CGSize(width: s, height: s)
            minimumInteritemSpacing = 0
            minimumLineSpacing = 0
            
            // 提示：如果在 iPhone 4s 上运行，由于浮点数的精度问题，会只显示两行
            let y = (collectionView!.bounds.height - 3 * s) * 0.45
            sectionInset = UIEdgeInsets(top: y, left: 0, bottom: y, right: 0)
            
            scrollDirection = UICollectionViewScrollDirection.Horizontal
        }
    }
    /// 表情分组数据
    private lazy var packages: [EmoticonPackage] = EmoticonPackage.packagesList
}

extension EmoticonViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    ///  返回分组数量
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return packages.count
    }
    
    ///  返回每一个分组中，表情的数量
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packages[section].emoticons?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HMEmoticonKeyboardIdentifier, forIndexPath: indexPath) as! EmoticonCell
        
        cell.emoticon = packages[indexPath.section].emoticons![indexPath.item]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // 获取用户选中的 表情
        let emoticon = packages[indexPath.section].emoticons![indexPath.item]
        
        // 判断表情符号是否有效
        if emoticon.chs != nil || emoticon.emoji != nil {
            emoticon.times++
            // 将表情添加到 `最近的` emoticons 数组
            packages[0].addFavoriteEmoticon(emoticon)
        }
        
        didSelectedEmoticonCallBack(emoticon: emoticon)
    }
}

private class EmoticonCell: UICollectionViewCell {

    /// 表情模型
    var emoticon: Emoticon? {
        didSet {
            // 设置图片 - 使用 path 只需要计算一次！
            if let path = emoticon?.imagePath {
                emoticonButton.setImage(UIImage(contentsOfFile: path), forState: UIControlState.Normal)
            } else {
                // 防止 cell 的重用
                emoticonButton.setImage(nil, forState: UIControlState.Normal)
            }
            
            // 设置 emoji - 直接过滤调用 cell 重用的问题
            emoticonButton.setTitle(emoticon!.emoji ?? "", forState: UIControlState.Normal)
            
            // 设置删除按钮
            if emoticon!.removeButton {
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete"), forState: UIControlState.Normal)
                emoticonButton.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: UIControlState.Highlighted)
            }
        }
    }
    
    // frame 的大小已经被设置，原因：是因为 layout 属性已经设置完成
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 添加按钮
        addSubview(emoticonButton)
        emoticonButton.frame = CGRectInset(bounds, 4, 4)
        emoticonButton.backgroundColor = UIColor.whiteColor()
        emoticonButton.titleLabel?.font = UIFont.systemFontOfSize(32)
        // 禁止按钮交互
        emoticonButton.userInteractionEnabled = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var emoticonButton = UIButton()
}
