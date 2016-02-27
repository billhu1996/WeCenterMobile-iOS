//
//  CommentHeaderView.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 16/2/23.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class CommentHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var commentCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(commentCount: Int, likeCount: Int) {
        commentCountLabel.text = "\(commentCount)评论"
        likeCountLabel.text = "\(likeCount) 赞"
        setNeedsLayout()
        layoutIfNeeded()
    }
}
