//
//  PhotoBrowserViewController.swift
//  Weibo007
//
//  Created by apple on 15/7/3.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import SVProgressHUD

class PhotoBrowserViewController: UIViewController {

    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func save() {

        // 1. 拿到图像
        let image = currentImageView().image!
        
        // 2. 保存图像 - 回调方法的参数格式是固定的
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    ///  返回当前显示图片的索引
    func currentImageIndex() -> Int {
        return collectionView.indexPathsForVisibleItems().last!.item
    }
    
    ///  获得当前显示的 图像视图
    func currentImageView() -> UIImageView {
        // 0. 拿到当前的cell
        let indexPath = collectionView.indexPathsForVisibleItems().last
        let cell = collectionView.cellForItemAtIndexPath(indexPath!) as! PhotoViewerCell
        
        // 1. 拿到图像
        return cell.imageView
    }
    
    // - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    func image(image :UIImage, didFinishSavingWithError error:NSError?, contextInfo :AnyObject) {
     
        if error != nil {
            SVProgressHUD.showErrorWithStatus("保存出错")
        } else {
            SVProgressHUD.showSuccessWithStatus("保存成功")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(imageURLs)
    }
    
    // 将要出现，视图 OK，collectionView 不 OK
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print("\(__FUNCTION__) \(view.frame) \(collectionView.frame)")
    }
    
    // 将要布局，视图 OK，collectionView 不 OK
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print("\(__FUNCTION__) \(view.frame) \(collectionView.frame)")
    }
    
    // 完成子视图，视图 OK，collectionView OK
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        print("\(__FUNCTION__) \(view.frame) \(collectionView.frame)")
        
        prepareLayout()
        
        // 跳转到用户选定的页面
        let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
    }
    
    // 提示：滚动到指定位置，不要写在此方法中
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        // 跳转到用户选定的页面
//        let indexPath = NSIndexPath(forItem: currentIndex, inSection: 0)
//        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
//    }
    
    private func prepareLayout() {
        // 设定所有的 item 的尺寸
        layout.itemSize = collectionView.bounds.size
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        
        collectionView.pagingEnabled = true
    }
    
    override func loadView() {
        // 将视图的大小`设大`
        var screenBounds = UIScreen.mainScreen().bounds
        screenBounds.size.width += 20
        view = UIView(frame: screenBounds)
        
        view.backgroundColor = UIColor.blackColor()
        view.addSubview(collectionView)
        view.addSubview(saveButton)
        view.addSubview(closeButton)
        
        collectionView.ff_Fill(view)
        saveButton.ff_AlignInner(ff_AlignType.BottomRight, referView: view, size: CGSize(width: 60, height: 30), offset: CGPoint(x: -12, y: -12))
        closeButton.ff_AlignInner(ff_AlignType.BottomLeft, referView: view, size: CGSize(width: 60, height: 30), offset: CGPoint(x: 12, y: -12))
        
        saveButton.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
        closeButton.addTarget(self, action: "close", forControlEvents: UIControlEvents.TouchUpInside)
        
        prepareCollectionView()
    }
    
    private func prepareCollectionView() {
        collectionView.backgroundColor = UIColor.clearColor()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(PhotoViewerCell.self, forCellWithReuseIdentifier: HMPhotoBrowserCellReuseIdentifier)
    }
    
    init(urls: [NSURL], index: Int) {
        // 先初始化本类的属性
        imageURLs = urls
        currentIndex = index
        
        // `再`调用系统提供的 `父类` 构造函数
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 图像的数组 
    private var imageURLs: [NSURL]
    /// 用户选中的照片索引
    private var currentIndex: Int
    
    // MARK: － 控件懒加载
    lazy private var layout = UICollectionViewFlowLayout()
    lazy private var collectionView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.layout)
    lazy private var saveButton: UIButton = UIButton(title: "保存", fontSize: 14)
    lazy private var closeButton: UIButton = UIButton(title: "关闭", fontSize: 14)
    
    /// 照片的缩放比例，与 OC 类似，分类中同样不能包含存储性属性
    private var photoScale: CGFloat = 0
}

private let HMPhotoBrowserCellReuseIdentifier = "HMPhotoBrowserCellReuseIdentifier"

extension PhotoBrowserViewController: UICollectionViewDataSource, UICollectionViewDelegate, PhotoViewerCellDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HMPhotoBrowserCellReuseIdentifier, forIndexPath: indexPath) as! PhotoViewerCell
        
        cell.backgroundColor = UIColor.clearColor()
        cell.imageURL = imageURLs[indexPath.item]
        
        cell.photoDelegate = self
        
        return cell
    }

    // 全屏状态下，此方法不会被触发
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print(__FUNCTION__)
    }
    
    // 点击关闭
    func photoViewerCellDidTapImage() {
        // 关闭界面
        close()
    }
    
    ///  缩放进行中
    func photoViewerDidZooming(scale: CGFloat) {
        print(scale)
        // 交互式转场
        // 记录缩放比例
        photoScale = scale
        
        // 隐藏控件
        hideControl(photoScale < 1.0)
        
        // 判断如果缩放比例小于 1，开始交互式转场
        if photoScale < 1.0 {
            startInteractiveTransition(self)
        } else {
            // 恢复形变
            view.transform = CGAffineTransformIdentity
            view.alpha = 1.0
        }
    }
    
    func photoViewerDidEndZoom() {
        // 判断当前的缩放比例
        if photoScale < 0.8 {
            // 直接关闭 － 告诉转场动画结束
            completeTransition(true)
        } else {
            // 恢复控件
            hideControl(false)
            
            // 恢复形变
            view.transform = CGAffineTransformIdentity
            view.alpha = 1.0
        }
    }
    
    ///  隐藏控件
    private func hideControl(isHidden: Bool) {
        view.backgroundColor = isHidden ? UIColor.clearColor() : UIColor.blackColor()
        saveButton.hidden = isHidden
        closeButton.hidden = isHidden
    }
}

extension PhotoBrowserViewController: UIViewControllerInteractiveTransitioning, UIViewControllerContextTransitioning {
    
    ///  transitionContext 是提供专场所需的所有信息
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        // 缩放视图
        view.transform = CGAffineTransformMakeScale(photoScale, photoScale)
        // 设置透明度
        view.alpha = photoScale
    }
    
    ///  转场动画中，这个函数很重要，告诉转场动画结束
    func completeTransition(didComplete: Bool) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func containerView() -> UIView? { return self.view.superview }
    func isAnimated() -> Bool { return true }
    func isInteractive() -> Bool { return true }
    func transitionWasCancelled() -> Bool { return true }
    func presentationStyle() -> UIModalPresentationStyle { return UIModalPresentationStyle.Custom }
    func updateInteractiveTransition(percentComplete: CGFloat) {}
    func finishInteractiveTransition() {}
    func cancelInteractiveTransition() {}
    
    func viewControllerForKey(key: String) -> UIViewController? { return self }
    func viewForKey(key: String) -> UIView? { return self.view }
    func targetTransform() -> CGAffineTransform { return CGAffineTransformIdentity }
    
    func initialFrameForViewController(vc: UIViewController) -> CGRect { return CGRectZero }
    func finalFrameForViewController(vc: UIViewController) -> CGRect { return CGRectZero }
}
