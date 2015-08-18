//
//  NewFeatureViewController.swift
//  Weibo007
//
//  Created by apple on 15/6/26.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class NewFeatureViewController: UICollectionViewController {

    /// 界面布局
    let layout = UICollectionViewFlowLayout()
    
    init() {
        super.init(collectionViewLayout: layout)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 注册可重用 cell
        self.collectionView!.registerClass(NewFeatureCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    // 关于生命周期的方法，不要死记硬背，最好log确认最合适的方法
    // 提示：从 iOS 7.0 开始，就不建议在 viewDidLoad 中设置控件大小和位置
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(self.collectionView?.frame)
        // 设置布局
        layout.itemSize = view.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        // 设置分页
        collectionView?.pagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
    }

    // MARK: UICollectionViewDataSource
    /// 图片总数
    let imageCount = 4
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCount
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NewFeatureCell
    
        // Configure the cell
        cell.imageIndex = indexPath.item
    
        return cell
    }
    
    ///  collectionView 停止滚动的动画方法
    ///
    ///  :param: collectionView collectionView
    ///  :param: cell           之前显示的 cell
    ///  :param: indexPath      之前显示的 indexPath
    override func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        // 获取当前显示的 cell
        let path = collectionView.indexPathsForVisibleItems().last!
        
        if path.item == imageCount - 1 {
            // 获取cell，让cell播放动画
            (collectionView.cellForItemAtIndexPath(path) as! NewFeatureCell).showStartButton()
        }
    }
}

class NewFeatureCell: UICollectionViewCell {
    
    /// 图像索引
    var imageIndex: Int = 0 {
        didSet {
            iconView.image = UIImage(named: "new_feature_\(imageIndex + 1)")
            
            startButton.hidden = true
        }
    }
    
    ///  动画显示开始按钮
    func showStartButton() {
        // 动画
        startButton.transform = CGAffineTransformMakeScale(0, 0)
        startButton.hidden = false
        startButton.userInteractionEnabled = false
        
        UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.startButton.transform = CGAffineTransformIdentity
            }, completion: { (_) -> Void in
                print("OK")
                self.startButton.userInteractionEnabled = true
        })
    }
    
    /// 点击开始按钮
    func startButtonClicked() {
    
        // object = true 表示显示 MainViewController
        NSNotificationCenter.defaultCenter().postNotificationName(HMSwitchRootVCNotification, object: true)
    }
    
    // 图像
    lazy var iconView: UIImageView = {
        return UIImageView()
    }()
    
    // 开始按钮
    lazy var startButton: UIButton = {
        // 自定义按钮
        let btn = UIButton()
        btn.frame = CGRectMake(0, 0, 105, 36)
        
        btn.setTitle("开始体验", forState: UIControlState.Normal)
        
        btn.setBackgroundImage(UIImage(named: "new_feature_finish_button"), forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named: "new_feature_finish_button_highlighted"), forState: UIControlState.Highlighted)
        
        btn.addTarget(self, action: "startButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(iconView)
        addSubview(startButton)

        // 自动布局 － 一定要创建完控件就添加
        startButton.ff_AlignInner(ff_AlignType.BottomCenter, referView: self, size: nil, offset: CGPoint(x: 0, y: -160))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        iconView.frame = self.bounds
    }
}
