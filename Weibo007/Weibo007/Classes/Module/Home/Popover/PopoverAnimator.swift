//
//  PopoverAnimator.swift
//  Weibo007
//
//  Created by apple on 15/6/26.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit


/// UIViewControllerTransitioningDelegate 提供转场动画相关的对象
/// UIViewControllerAnimatedTransitioning 提供转场动画的实现
class PopoverAnimator: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {

    /// 展现视图的大小
    var presentFrame = CGRectZero
    
    /// 是否展现的标记
    var isPresented = false
    
    // 返回负责转场的控制器对象
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        
        let pc = PopoverPresentationController(presentedViewController: presented, presentingViewController: presenting)
        
        pc.presentFrame = presentFrame
        
        return pc
    }
    
    // 返回提供 Modal 动画的对象
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresented = true
        return self
    }
    
    // 返回提供 Dismissed 动画的对象
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPresented = false
        return self
    }
    
    // 动画时长
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        
        return isPresented ? 1.2 : 0.25
    }
    
    ///  转场动画实现函数 － 一旦实现此函数，默认的动画实效，所有的动画由程序员提供
    ///
    ///  :param: transitionContext 转场上下文，提供了转场所需的参数
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 判断是展现还是 dismiss
        if isPresented {
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            // 1. 将 toView 添加到容器视图
            transitionContext.containerView()?.addSubview(toView)
            
            // 2. 动画实现
            toView.transform = CGAffineTransformMakeScale(1.0, 0)
            toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                
                toView.transform = CGAffineTransformIdentity
                
                }, completion: { (_) -> Void in
                    // 3. *** 结束动画 - 告诉系统转场动画已经结束
                    transitionContext.completeTransition(true)
            })
        } else {
            // 1. 取消 － fromView 删除
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            
            UIView.animateWithDuration(transitionDuration(transitionContext), animations: { () -> Void in
                // y 设置一个非常小的值就能够动画了
                fromView.transform = CGAffineTransformMakeScale(1.0, 0.0001)
                }, completion: { (_) -> Void in
                    
                    // 2. 删除 fromView（展现的视图）
                    fromView.removeFromSuperview()
                    // 3. *** 结束动画 - 告诉系统转场动画已经结束
                    transitionContext.completeTransition(true)
            })
        }
    }
}
