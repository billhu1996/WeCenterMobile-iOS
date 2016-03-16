
//
//  ArticleAgreementActionCell.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 16/3/6.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticleAgreementActionCell: UITableViewCell {
    
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
        let action = action as! ArticleAgreementAction
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
        dateLabel.text = dateLabel.text! + "赞了"
        articleTitleLabel.text = action.article!.title
        viewCountLabel.text = "\(action.article!.viewCount!)"
        userButton.msr_userInfo = action.user
        articleButton.msr_userInfo = action.article
        setNeedsLayout()
        layoutIfNeeded()
    }
}
