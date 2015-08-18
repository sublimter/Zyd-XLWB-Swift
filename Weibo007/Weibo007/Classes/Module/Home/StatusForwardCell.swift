//
//  StatusForwardCell.swift
//  Weibo007
//
//  Created by apple on 15/7/2.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class StatusForwardCell: StatusCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 初始化转发微博标签
        forwardLabel = UILabel(color: UIColor.darkGrayColor(), fontSize: 14, mutiLines: true)
        forwardLabel!.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.width - 16
        insertSubview(forwardLabel!, atIndex: 0)
        
        forwardButton.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        insertSubview(forwardButton, atIndex: 0)
        
        // 自动布局
        // 背景按钮
        forwardButton.ff_AlignVertical(ff_AlignType.BottomLeft, referView: contentLabel, size: nil, offset: CGPoint(x: -12, y: 12))
        forwardButton.ff_AlignVertical(ff_AlignType.TopRight, referView: footerView, size: nil)
        // 转发文字
        forwardLabel!.ff_AlignInner(ff_AlignType.TopLeft, referView: forwardButton, size: nil, offset: CGPoint(x: 12, y: 12))
        
        // 配图视图
        recordPictureViewCons(pictureView.ff_AlignVertical(ff_AlignType.BottomLeft, referView: forwardLabel!, size: CGSizeMake(290, 90), offset: CGPoint(x: 0, y: 12)))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: 懒加载控件
    lazy var forwardButton = UIButton()
}
