//
//  HomeTableViewController.swift
//  Weibo007
//
//  Created by apple on 15/6/23.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import SVProgressHUD

class HomeTableViewController: BaseTableViewController, StatusCellDelegate {

    /// 表格绑定的微博数据数组
    var statusesList: [Status]? {
        didSet {
            // 刷新表格
            tableView.reloadData()
        }
    }
    
    // 定义行高缓存 [statusId: 行高]
    lazy var rowHeightCache = [Int: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        visitorView?.setupViewInfo("visitordiscover_feed_image_house", message: "关注一些人，回这里看看有什么惊喜", isHome: true)
        
        // 如果用户没有登录，直接返回
        if !userLogon {
            return
        }
        
        // 以下代码都是用户登录后才需要执行的
        setupNavigationBar()
        prepareTableView()
        prepareRefresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // 清空缓存，提示：NSCache 不能清空
        rowHeightCache.removeAll()
    }
    
    ///  加载微博数据
    func loadData() {
        
        // 开始刷新-不会触发监听方法，会显示刷新控件
        refreshControl?.beginRefreshing()
        
        // 下拉刷新的代号，取到数组中第1条数据的 id
        var since_id = statusesList?.first?.id ?? 0
        
        // 上拉刷新，取到数组中最后1条数据的 id
        var max_id = 0
        if pullRefreshFlag {
            since_id = 0
            max_id = statusesList?.last?.id ?? 0
        }
        
        Status.loadStatus(since_id, max_id: max_id) { (statuses, error) -> () in
            
            // 关闭刷新控件
            self.refreshControl?.endRefreshing()
            
            if error != nil {
                // 不要把错误的相信信息告诉用户，程序员应该多测试！
                SVProgressHUD.showInfoWithStatus("您的网络不给力")
                return
            }
            
            // 提示，后续会有下拉刷新，没有新微博的情况，不要抱错！
            if statuses == nil {
                print("没有数据")
                return
            }
            
            // 跟踪转发微博
            print("加载了 \(statuses?.count) 条微博")
            
            // 判断是否是下拉刷新，将新的数据，添加到原有数组的前面
            if since_id > 0 {
                self.statusesList = statuses! + self.statusesList!
            } else if max_id > 0 {
                // 上拉刷新
                self.statusesList = self.statusesList! + statuses!
                self.pullRefreshFlag = false
            } else {
                // 初始刷新
                self.statusesList = statuses
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // 开启动画
        visitorView?.startAnmiation()
    }
    
    // MARK: - 表格的数据源方法
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusesList?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 1. 取得 数据模型
        let status = statusesList![indexPath.row]
        
        // 2. 取表示符
        let ID = StatusCell.cellIdentifier(status)
        
        // 此方法必须注册可重用cell，如果不注册，会崩溃
        let cell = tableView.dequeueReusableCellWithIdentifier(ID, forIndexPath: indexPath) as! StatusCell
        
        // 设置代理
        cell.photoDelegate = self
     
        // 设置 cell
        cell.status = status
        
        // 判断是否是最后一行
        if indexPath.row == statusesList!.count - 1 {
            pullRefreshFlag = true
            loadData()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // 1. 取到对象
        let status = statusesList![indexPath.row]
        
        // 1.1 判断是否缓存了行高，如果有直接返回
        if rowHeightCache[status.id] != nil {
            return rowHeightCache[status.id]!
        }
        
        // 2. 获取 cell － 从可重用的 缓冲池 中提取一个cell，说明之前用过，要计算行高准确，需要实例化一个cell
        // Xcode 7.0 新发现的
        // 2.1 取可重用的 ID
        let ID = StatusCell.cellIdentifier(status)
        // 2.2 定义一个类，默认是原创微博的 cell
        var cls: AnyClass = StatusNormalCell.self
        // 2.3 根据 ID 判断是否是转发微博
        if ID == HMStatusForwardCellIdentifier {
            cls = StatusForwardCell.self
        }
        // 2.4 根据 cls 创建 cell
        let cell = cls.new() as! StatusCell
        
        // 3. 返回行高
        let height = cell.rowHeight(status)
        rowHeightCache[status.id] = height
        return height
    }
    
    // MARK: - Cell 的代理方法
    func statusCellDidSelectedPhoto(cell: StatusCell, photoIndex: Int) {
        if cell.status?.largePicURLs == nil {
            return
        }
        
        // 传递数据！- 图像的数组 & 用户选中的照片索引
        let vc = PhotoBrowserViewController(urls: cell.status!.largePicURLs!, index: photoIndex)
        
        // 0. 准备转场的素材
        presentedImageView.sd_setImageWithURL(cell.status!.largePicURLs![photoIndex])
        presentedImageView.frame = cell.screenFrame(photoIndex)
        presentedImageView.contentMode = UIViewContentMode.ScaleAspectFill
        // 目标位置
        presentedFrame = cell.fullScreenFrame(photoIndex)
        // 记录当前行
        selectedStatusCell = cell
        
        // 1. 设置转场代理
        vc.transitioningDelegate = self
        // 2. 设置转场的样式
        vc.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
    ///  1. 临时的图片视图
    private lazy var presentedImageView = UIImageView()
    ///  2. 目标位置
    private var presentedFrame = CGRectZero
    ///  3. 用户选中照片的表格行
    private var selectedStatusCell: StatusCell?

    ///  显示二维码界面
    func showQRCode() {
        let sb = UIStoryboard(name: "QRCode", bundle: nil)
        presentViewController(sb.instantiateInitialViewController()!, animated: true, completion: nil)
    }
    
    /// 动画转场代理
    let popoverAnimator = PopoverAnimator()
    
    func titleButtonClicked() {
        let sb = UIStoryboard(name: "FriendGroup", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("FriendGroupSB")
        
        // 1. 设置`转场 transitioning`代理
        vc.transitioningDelegate = popoverAnimator
        // 2. 设置视图的展现大小
        let x = (view.bounds.width - 200) * 0.5
        popoverAnimator.presentFrame = CGRectMake(x, 56, 200, 300)
        // 3. 设置专场的模式 - 自定义转场动画
        vc.modalPresentationStyle = UIModalPresentationStyle.Custom
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
    // MARK: - 设置 UI
    /// 设置导航条
    private func setupNavigationBar() {
        // 判断用户是否登录
        if sharedUserAccount == nil {
            return
        }
        
        // 1. 设置按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "navigationbar_friendsearch", highlightedImageName: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "navigationbar_pop", highlightedImageName: nil)
        print(navigationItem.rightBarButtonItem?.customView)
        // 1.1 获取 button
        let btn = navigationItem.rightBarButtonItem!.customView as! UIButton
        // 1.2 添加 target
        btn.addTarget(self, action: "showQRCode", forControlEvents: UIControlEvents.TouchUpInside)
        
        // 2. 设置标题
        let titleButton = HomeTitleButton.button(sharedUserAccount!.name!)
        
        titleButton.addTarget(self, action: "titleButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        
        navigationItem.titleView = titleButton
    }
    
    ///  准备 tableView
    private func prepareTableView() {
        // 注册可重用 cell
        tableView.registerClass(StatusForwardCell.self, forCellReuseIdentifier: HMStatusForwardCellIdentifier)
        tableView.registerClass(StatusNormalCell.self, forCellReuseIdentifier: HMStatusNormalCellIdentifier)
        // 取消分隔线
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    ///  准备刷新控件
    private func prepareRefresh() {
        refreshControl = HMRefreshControl()
        
        // 添加监听方法
        refreshControl?.addTarget(self, action: "loadData", forControlEvents: UIControlEvents.ValueChanged)
        
        // 加载数据
        loadData()
    }
    
    /// 上拉刷新标记
    private var pullRefreshFlag = false
    
    private var isPresented = false
}

extension HomeTableViewController: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
 
    // 返回提供转场 Modal 动画的对象
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresented = true
        return self
    }
    
    // 返回提供转场 Dismiss 动画的对象
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresented = false
        return self
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    // 一旦实现，需要程序员提供动画
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 1. 获取目标视图
        let viewKey = isPresented ? UITransitionContextToViewKey : UITransitionContextFromViewKey
        let targetView = transitionContext.viewForKey(viewKey)
        
        if targetView == nil {
            return
        }
        
        if isPresented {
            // 2. 添加 toView
            transitionContext.containerView()?.addSubview(targetView!)
            targetView!.alpha = 0
            // 2.1 添加临时的图片视图
            transitionContext.containerView()?.addSubview(presentedImageView)
            
            // 3. 动画
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                
                self.presentedImageView.frame = self.presentedFrame

                }, completion: { (_) -> Void in
                    // 删除临时图片视图
                    self.presentedImageView.removeFromSuperview()
                    
                    targetView!.alpha = 1
                    // *** 告诉动画完成
                    transitionContext.completeTransition(true)
            })
        } else {
            
            // 0. 获取要缩放的图片
            let targetVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! PhotoBrowserViewController
            let iv = targetVC.currentImageView()
            iv.contentMode = UIViewContentMode.ScaleAspectFill
            
            // 叠加形变
            iv.transform = CGAffineTransformScale(iv.transform, targetView!.transform.a, targetView!.transform.a)
            // 设置图像视图的中心点
            iv.center = targetView!.center
            
            // 1. 添加到容器视图
            transitionContext.containerView()?.addSubview(iv)
            // 2. 将目标视图直接删除
            targetView?.removeFromSuperview()
            
            // 3. 恢复的位置
            let targetFrame = selectedStatusCell!.screenFrame(targetVC.currentImageIndex())
            
            // 4. 动画
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                
                iv.frame = targetFrame
                
                }, completion: { (_) -> Void in
                    iv.removeFromSuperview()
                    transitionContext.completeTransition(true)
            })
        }
    }
}