//
//  PhotoViewerCell.swift
//  Weibo007
//
//  Created by apple on 15/7/3.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import SDWebImage

protocol PhotoViewerCellDelegate: NSObjectProtocol {
    func photoViewerCellDidTapImage()
    ///  照片视图正在缩放
    func photoViewerDidZooming(scale: CGFloat)
    ///   照片视图完成缩放
    func photoViewerDidEndZoom()
}

class PhotoViewerCell: UICollectionViewCell, UIScrollViewDelegate {
    
    weak var photoDelegate: PhotoViewerCellDelegate?
    
    var imageURL: NSURL? {
        didSet {
            // 重设 scrollView
            resetScrollView()
            
            // 显示菊花
            indicator.startAnimating()
            
            imageView.sd_setImageWithURL(imageURL!, placeholderImage: nil) { (image, error, _, _) in

                // 隐藏菊花
                self.indicator.stopAnimating()
                self.imagePostion(image)
            }
        }
    }
    
    ///  重设 scrollView 内容参数
    private func resetScrollView() {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointZero
        scrollView.contentSize = CGSizeZero
        
        // 重新设置 imageView 的transform
        imageView.transform = CGAffineTransformIdentity
    }
    
    // MARK: - UIScrollViewDelegate 
    ///  告诉 scrollView 缩放谁
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    ///  缩放结束，会执行一次
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        
        // 如果 scale < 0.8 直接解除转场
        if scale >= 0.8 {
            // 重新计算边距
            var offsetX = (scrollView.bounds.width - view!.frame.width) * 0.5
            if offsetX < 0 {
                offsetX = 0
            }
            var offsetY = (scrollView.bounds.height - view!.frame.height) * 0.5
            if offsetY < 0 {
                offsetY = 0
            }
            // 重新设置边距
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
        }
        
        // 通知代理完成缩放
        photoDelegate?.photoViewerDidEndZoom()
    }
    
    ///  缩放过程中，会频繁调用
    /**
        var a: CGFloat  缩放
        var b: CGFloat
        var c: CGFloat
        var d: CGFloat  缩放
        var tx: CGFloat 位移
        var ty: CGFloat 位移
    
        a, b, c, d, 共同决定旋转
    */
    func scrollViewDidZoom(scrollView: UIScrollView) {
        // 拿到缩放比例
        let scale = imageView.transform.a
        photoDelegate?.photoViewerDidZooming(scale)
    }
    
    /// 设置位置
    private func imagePostion(image: UIImage) {
        
        // 计算 y 值
        let size = displaySize(image)
        
        // 判断是否是长图
        if bounds.height < size.height {
            imageView.frame = CGRect(origin: CGPointZero, size: size)
            scrollView.contentSize = size
        } else {
            // 短图
            let y = (bounds.height - size.height) * 0.5
//            imageView.frame = CGRect(origin: CGPoint(x: 0, y: y), size: size)
            // 设置 scrollView 的边距
            imageView.frame = CGRect(origin: CGPointZero, size: size)
            scrollView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: 0, right: 0)
        }
    }
    
    ///  根据图像计算显示的尺寸
    private func displaySize(image: UIImage) -> CGSize {
        
        let scale = image.size.height / image.size.width
        let h = scrollView.bounds.width * scale
        
        return CGSize(width: scrollView.bounds.width, height: h)
    }
    
    func clickImage() {
        photoDelegate?.photoViewerCellDidTapImage()
    }
    
    // frame 已经有正确的数值！是因为之前 layout 已经设置过 itemSize
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print("Cell 的大小 \(frame)")
        
        scrollView.frame = UIScreen.mainScreen().bounds
        addSubview(scrollView)
        scrollView.backgroundColor = UIColor.clearColor()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 2.0
        
        scrollView.addSubview(imageView)
        
        // 设置 imageView 的手势监听
        let tap = UITapGestureRecognizer(target: self, action: "clickImage")
        imageView.addGestureRecognizer(tap)
        imageView.userInteractionEnabled = true
        
        addSubview(indicator)
        indicator.ff_AlignInner(ff_AlignType.CenterCenter, referView: self, size: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 懒加载控件
    lazy var imageView = UIImageView()
    lazy private var scrollView = UIScrollView()
    lazy private var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
}
