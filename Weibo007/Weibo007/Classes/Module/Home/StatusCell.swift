//
//  StatusCell.swift
//  Weibo007
//
//  Created by apple on 15/6/30.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit
import SDWebImage

protocol StatusCellDelegate: NSObjectProtocol {
    ///  选中照片代理方法
    func statusCellDidSelectedPhoto(cell: StatusCell, photoIndex: Int)
}

/// 转发微博 cell
let HMStatusForwardCellIdentifier = "HMStatusForwardCellIdentifier"
/// 原创微博 cell
let HMStatusNormalCellIdentifier = "HMStatusNormalCellIdentifier"

/// 图片视图可重用标示符
private let HMPictureCellReuseIdentifier = "HMPictureCellReuseIdentifier"

class StatusCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    /// 照片代理 - 提示，不要用 delegate
    weak var photoDelegate: StatusCellDelegate?
    /// 转发微博标签
    var forwardLabel: UILabel?
    
    ///  微博数据模型
    var status: Status? {
        didSet {
            // 转发文字
            let forwardText = (status?.retweeted_status?.user?.name ?? "") + ": " + (status?.retweeted_status?.text ?? "")
            forwardLabel?.attributedText = EmoticonPackage.emoticonAttributeString(forwardText, font: forwardLabel!.font)
            
            // 设置头像
            iconView.sd_setImageWithURL(status?.user?.profileURL)
            // 设置认证图标
            vipIconView.image = status?.user?.verifiedImage
            // 设置会员图标
            memberIconView.image = status?.user?.mbImage
            
            nameLabel.text = status?.user?.name
            timeLabel.text = NSDate.sinaDateWithString(status?.created_at ?? "").dateDescription()
            
            sourceLabel.text = status?.source
            contentLabel.attributedText = EmoticonPackage.emoticonAttributeString(status?.text ?? "", font: contentLabel.font)
            
            // 计算图片视图的大小
            let result = calcPictureViewSize(status!)
            
            // 设置配图视图约束大小
            // 没有图片，需要处理顶部约束
            topCons?.constant = result.viewSize.height == 0 ? 0 : 12
            widthCons?.constant = result.viewSize.width
            heightCons?.constant = result.viewSize.height
            pictureLayout.itemSize = result.itemSize
            
            // 刷新图片视图
            pictureView.reloadData()
        }
    }
    
    /// cell 的可重用 标示符
    class func cellIdentifier(status: Status) -> String {
        return status.retweeted_status != nil ? HMStatusForwardCellIdentifier : HMStatusNormalCellIdentifier
    }
    
    ///  计算行高
    func rowHeight(status: Status) -> CGFloat {
        // 给模型设置数值，调用 didSet 方法
        self.status = status
        
        // 更新布局
        layoutIfNeeded()
        
        // 返回行高 - 页脚视图的底边
        return CGRectGetMaxY(footerView.frame)
    }
    
    // MARK: - 数据源方法
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return status?.picURLs?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(HMPictureCellReuseIdentifier, forIndexPath: indexPath) as! StatusPictureCell
        
        // 调用此数据源方法，说明上面的数据行数有效，证明数组一定有内容
        cell.imageURL = status!.picURLs![indexPath.item]
        
        return cell
    }
    
    ///  返回大图对应的全屏之后的屏幕位置
    func fullScreenFrame(photoIndex: Int) -> CGRect {
        
        // 0. 取得已经缓存的图片
        let urlString = status!.picURLs![photoIndex].absoluteString
        let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(urlString)
        
        // 1. 计算比例
        let scale = image.size.height / image.size.width
        let screenSize = UIScreen.mainScreen().bounds.size
        
        let w = screenSize.width
        let h = w * scale
        var y: CGFloat = 0
        
        if h < screenSize.height {
            y = (screenSize.height - h) * 0.5
        }
        
        return CGRect(x: 0, y: y, width: w, height: h)
    }
    
    ///  取得指定图片索引的屏幕 frame
    func screenFrame(photoIndex: Int) -> CGRect{
        
        let indexPath = NSIndexPath(forItem: photoIndex, inSection: 0)
        let cell = pictureView.cellForItemAtIndexPath(indexPath) as! StatusPictureCell
        
        // 让 collectionView 将 内部 cell 的坐标转换到 keyWindow 的坐标系
        return pictureView.convertRect(cell.frame, toCoordinateSpace: UIApplication.sharedApplication().keyWindow!)
    }
    
    ///  选中照片代理方法
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // 预先加载大图
        // 0. 取出大图的 URL
        let url = status!.largePicURLs![indexPath.item]
        let cell = pictureView.cellForItemAtIndexPath(indexPath) as! StatusPictureCell
        
        // 1. 使用 sdwebImage 缓存大图
        // 注意：如果图片已经存在缓存，不会出发进度回调
        // 进度回调是异步的！
        SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: { (bytes, totalBytes) -> Void in
            
//            print("\(bytes) \(totalBytes) \(NSThread.currentThread())")
            
            // 设置进度
            let progress = CGFloat(bytes) / CGFloat(totalBytes)
            
            dispatch_async(dispatch_get_main_queue()) {
                cell.iconView.progress = progress
            }
            
            }) { [unowned self] (_, error, _, _, _) -> Void in
                print("\(error)")
                
                // 大图缓存结束后，再执行回调
                // 照片索引只需要传递 `Int` 会简化调用方的使用
                self.photoDelegate?.statusCellDidSelectedPhoto(self, photoIndex: indexPath.item)
        }
    }
    
    ///  记录配图视图约束
    func recordPictureViewCons(cons: [NSLayoutConstraint]) {
        topCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Top)
        widthCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Width)
        heightCons = pictureView.ff_Constraint(cons, attribute: NSLayoutAttribute.Height)
    }
    
    ///  根据微博模型计算图片是的大小
    /**
        0. 没有图片，返回zero
        1. 单图会按照图片等比例显示
        2. 多图的图片大小固定
        3. 多图如果是4张，会按照 2 * 2 显示
        4. 多图其他数量，按照 3 * 3 九宫格显示
    
        返回多个数值，在 OC 中指针的指针，在 swift 中，元组，参数，可以直接在返回结果用 . 语法访问
    */
    private func calcPictureViewSize(status: Status) -> (viewSize: CGSize, itemSize: CGSize) {
        
        // 0. 获取图片数量
        let itemSize = CGSize(width: 90, height: 90)
        let margin: CGFloat = 10
        
        let count = status.picURLs?.count ?? 0
        
        // 1. 没有图片
        if count == 0 {
            return (CGSizeZero, itemSize)
        }
        
        // 2. 单图
        if count == 1 {
            // 1> 从缓存`拿到`并且创建 image
            // key 就是 url 的完整字符串，sdwebimage缓存图片文件名是对 url 的完整字符串 md5
            let key = status.picURLs![0].absoluteString
            let image = SDWebImageManager.sharedManager().imageCache.imageFromDiskCacheForKey(key)
            
            // 2> 返回 image.size
            return (image.size, image.size)
        }
        
        // 3. 4张图片
        if count == 4 {
            let w = itemSize.width * 2 + margin
            return (CGSize(width: w, height: w), itemSize)
        }
        
        // 4. 多张图片
        // 每行图片数量
        let rowCount = 3
        // 1> 计算行数 
        // 2,3 -> 1
        // 5,6 -> 2
        // 7,8,9 -> 3
        let row = (count - 1) / rowCount + 1
        let w = itemSize.width * CGFloat(rowCount) + CGFloat(rowCount - 1) * margin
        let h = itemSize.height * CGFloat(row) + CGFloat(row - 1) * margin
        
        return (CGSize(width: w, height: h), itemSize)
    }
    
    // 函数执行的时候，frame 是 (0.0, 0.0, 320.0, 44.0)，对于 iPhone 6 & 6+ 尺寸是不对的
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 屏幕宽度
        let screenWidth = UIScreen.mainScreen().bounds.width
        
        // 顶部视图
        let topView = UIView()
        topView.backgroundColor = UIColor(white: 0.5, alpha: 1.0)
        addSubview(topView)
        topView.ff_AlignInner(ff_AlignType.TopLeft, referView: self, size: CGSize(width: screenWidth, height: 10))
        
        addSubview(iconView)
        addSubview(nameLabel)
        addSubview(memberIconView)
        addSubview(vipIconView)
        addSubview(timeLabel)
        addSubview(sourceLabel)
        addSubview(contentLabel)
        contentLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 16
        addSubview(pictureView)
        addSubview(footerView)
        footerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        // 准备配图视图
        preparePictureView()
        
        // 头像
        iconView.ff_AlignInner(ff_AlignType.TopLeft, referView: self, size: CGSize(width: 34, height: 34), offset: CGPoint(x: 12, y: 22))
        nameLabel.ff_AlignHorizontal(ff_AlignType.TopRight, referView: iconView, size: nil, offset: CGPoint(x: 12, y: 0))
        memberIconView.ff_AlignHorizontal(ff_AlignType.CenterRight, referView: nameLabel, size: nil, offset: CGPoint(x: 12, y: 0))
        vipIconView.ff_AlignInner(ff_AlignType.BottomRight, referView: iconView, size: nil, offset: CGPoint(x: 8, y: 8))
        timeLabel.ff_AlignHorizontal(ff_AlignType.BottomRight, referView: iconView, size: nil, offset: CGPoint(x: 12, y: 0))
        sourceLabel.ff_AlignHorizontal(ff_AlignType.CenterRight, referView: timeLabel, size: nil, offset: CGPoint(x: 12, y: 0))
        contentLabel.ff_AlignVertical(ff_AlignType.BottomLeft, referView: iconView, size: nil, offset: CGPoint(x: 0, y: 12))
        
        // 页脚视图
        footerView.ff_AlignVertical(ff_AlignType.BottomLeft, referView: pictureView, size: CGSize(width: screenWidth, height: 44), offset: CGPoint(x: -12, y: 12))
    }
    
    ///  准备配图视图图
    private func preparePictureView() {
        // 1. 设置背景颜色
        pictureView.backgroundColor = UIColor.lightGrayColor()
        // 2. 数据源
        pictureView.dataSource = self
        pictureView.delegate = self
        
        // 3. 注册可重用cell
        pictureView.registerClass(StatusPictureCell.self, forCellWithReuseIdentifier: HMPictureCellReuseIdentifier)
        // 4. 设置 layout
        pictureLayout.minimumInteritemSpacing = 10
        pictureLayout.minimumLineSpacing = 10
    }

    ///  如果使用 sb & xib 开发，使用 fatalError 会直接崩掉
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 控件的懒加载
    lazy var iconView = UIImageView()
    lazy var nameLabel = UILabel(color: UIColor.darkGrayColor(), fontSize: 14)
    lazy var memberIconView: UIImageView = UIImageView(image: UIImage(named: "common_icon_membership_level1"))
    lazy var vipIconView: UIImageView = UIImageView(image: UIImage(named: "avatar_grassroot"))
    lazy var timeLabel = UILabel(color: UIColor.orangeColor(), fontSize: 10)
    lazy var sourceLabel = UILabel(color: UIColor.darkGrayColor(), fontSize: 10)
    lazy var contentLabel = UILabel(color: UIColor.darkGrayColor(), fontSize: 15, mutiLines: true)
    
    // 图像视图 - UICollectionView
    lazy var pictureLayout = UICollectionViewFlowLayout()
    lazy var pictureView: UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.pictureLayout)
    
    // 页脚视图 - 使用 私有类的 var 同样需要 private
    lazy var footerView: StatusFooterView = StatusFooterView()
    
    /// 配图视图宽度约束
    private var widthCons: NSLayoutConstraint?
    /// 配图视图高度约束
    private var heightCons: NSLayoutConstraint?
    /// 配图视图顶部约束
    private var topCons: NSLayoutConstraint?
}

/// 配图 Cell
private class StatusPictureCell: UICollectionViewCell {
    
    /// 图像地址
    var imageURL: NSURL? {
        didSet {
            iconView.progress = 0
            
            // 如果本地有`缓存`，直接加载本地缓存的图片，如果没有，会自动下载
            // SDWebImage 虽然支持 gif 格式，但是内存消耗比较大！
            iconView.sd_setImageWithURL(imageURL)
            
            // 根据 url 的扩展名，判断是否设置 gif / GIF
            gifIconView.hidden = !(imageURL!.absoluteString.pathExtension.lowercaseString == "gif")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 设置图片填充模式 - 等比例填充，需要裁切
        iconView.contentMode = UIViewContentMode.ScaleAspectFill
        // 两句需要配合使用
        iconView.clipsToBounds = true
        
        addSubview(iconView)
        // 与 collectionView 完全一致
        iconView.ff_Fill(self)
        
        addSubview(gifIconView)
        gifIconView.ff_AlignInner(ff_AlignType.BottomRight, referView: self, size: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var iconView: HMImageView = HMImageView()
    private lazy var gifIconView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "timeline_image_gif"))
        iv.hidden = true
        
        return iv
    }()
}

/// 页脚视图
class StatusFooterView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(forwardBtn)
        addSubview(commentBtn)
        addSubview(likeBtn)
        
        // 布局，水平平铺
        ff_HorizontalTile([forwardBtn, commentBtn, likeBtn], insets: UIEdgeInsetsZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var forwardBtn: UIButton = UIButton(title: "转发", imageName: "timeline_icon_retweet", fontSize: 12)
    lazy var commentBtn: UIButton = UIButton(title: "评论", imageName: "timeline_icon_comment", fontSize: 12)
    lazy var likeBtn: UIButton = UIButton(title: "点赞", imageName: "timeline_icon_unlike", fontSize: 12)
}
