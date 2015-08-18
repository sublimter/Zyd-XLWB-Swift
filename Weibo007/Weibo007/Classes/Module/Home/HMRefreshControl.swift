//
//  HMRefreshControl.swift
//  Weibo007
//
//  Created by apple on 15/7/2.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

/// 刷新控件
class HMRefreshControl: UIRefreshControl {
    
    override init() {
        super.init()
        
        addSubview(refreshView)
        
        refreshView.ff_AlignInner(ff_AlignType.CenterCenter, referView: self, size: CGSize(width: 150, height: 60))
        
        // KVO 监听 自己
        addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)
    }
    
    deinit {
        // 注销监听
        removeObserver(self, forKeyPath: "frame")
    }
    
    /**
        1. 向下拉，y值会越来越小，Y值为负数，控件就会显示
        2. 拉到一定程度，会自动刷新
        3. 如果向上推表格，刷新控件仍然在，没有消失，Y值会一直变大
    */
    /// 显示提示图标标记
    private var showTipFlag = false
    /// 正在加载标记
    private var loadingFlag = false
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if frame.origin.y > 0 {
            return
        }
        
        // 调试使用
//        print(frame)
        
        // 如果正在加载数据，就显示加载动画
        if refreshing && !loadingFlag {
            refreshView.startLoadingAnim()
            
            loadingFlag = true
            return
        }
        
        if frame.origin.y < -50 && !showTipFlag {
            print("翻过来")
            showTipFlag = true
            refreshView.rotateTipIcon(showTipFlag)
        } else if frame.origin.y >= -50 && showTipFlag {
            print("转过去")
            showTipFlag = false
            refreshView.rotateTipIcon(showTipFlag)
        }
    }
    
    override func endRefreshing() {
        super.endRefreshing()
        
        // 关闭动画
        refreshView.stopLoadingAnim()
        
        // 重设刷新标记
        loadingFlag = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 懒加载控件
    lazy var refreshView = HMRefreshView.refreshView()
}

/// 刷新视图
class HMRefreshView: UIView {
    
    @IBOutlet weak var tipIcon: UIImageView!
    @IBOutlet weak var loadingIcon: UIImageView!
    @IBOutlet weak var tipView: UIView!
    
    class func refreshView() -> HMRefreshView {
        return NSBundle.mainBundle().loadNibNamed("HMRefreshView", owner: nil, options: nil).last as! HMRefreshView
    }
    
    ///  旋转提示图标
    private func rotateTipIcon(clockWise: Bool) {
        
        var angle = M_PI
        angle += clockWise ? -0.01 : 0.01
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.tipIcon.transform = CGAffineTransformRotate(self.tipIcon.transform, CGFloat(angle))
        }
    }
    
    ///  开启加载动画
    private func startLoadingAnim() {
        
        tipView.hidden = true
        
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        
        anim.toValue = 2 * M_PI
        anim.repeatCount = MAXFLOAT
        anim.duration = 0.5
        
        loadingIcon.layer.addAnimation(anim, forKey: nil)
    }
    
    ///  停止动画
    private func stopLoadingAnim() {
        tipView.hidden = false
        
        loadingIcon.layer.removeAllAnimations()
    }
}
