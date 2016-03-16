//
//  ArticlePublishmentActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticlePublishmentActionCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var articleBodyLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var articleView: UIView!
    @IBOutlet weak var viewCountLabel: UILabel!
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
    }
    
    func update(action action: Action) {
        let action = action as! ArticlePublishmentAction
        if let urlString = action.article?.imageURL {
            if let url = NSURL(string: urlString) {
                detailImageView.cancelImageRequestOperation()
                detailImageView.setImageWithURL(url, placeholderImage: UIImage())
            }
        }
        userAvatarView.wc_updateWithUser(action.user)
        userNameLabel.text = action.user?.name ?? "匿名用户"
        articleBodyLabel.text = action.article?.body
        if let date = action.date {
            dateLabel.text = TimeDifferenceStringFromDate(date) + " "
        } else {
            dateLabel.text = ""
        }
        dateLabel.text = dateLabel.text! + "在读"
        articleTitleLabel.text = action.article!.title
        viewCountLabel.text = "\(action.article!.viewCount!)"
        userButton.msr_userInfo = action.user
        articleButton.msr_userInfo = action.article
        setNeedsLayout()
        layoutIfNeeded()
    }
}
