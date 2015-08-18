//
//  StatusNormalCell.swift
//  Weibo007
//
//  Created by apple on 15/7/2.
//  Copyright © 2015年 ZhuYaoDong. All rights reserved.
//

import UIKit

class StatusNormalCell: StatusCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 配图视图
        recordPictureViewCons(pictureView.ff_AlignVertical(ff_AlignType.BottomLeft, referView: contentLabel, size: CGSize(width: 290, height: 90), offset: CGPoint(x: 0, y: 12)))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
