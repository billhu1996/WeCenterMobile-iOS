//
//  FeaturedArticleCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/13.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class FeaturedArticleCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleDetailLabel: UILabel!
    @IBOutlet weak var articleViewCountLabel: UILabel!
    
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
    
    func update(object object: FeaturedObject) {
        let object = object as! FeaturedArticle
        let article = object.article!
        if let url = article.imageURL {
            articleImageView.setImageWithURL(NSURL(string: url))
        }
        userAvatarView.wc_updateWithUser(article.user)
        userNameLabel.text = article.user?.name ?? "匿名用户"
        articleTitleLabel.text = article.title
        articleButton.msr_userInfo = article
        userButton.msr_userInfo = article.user
        if let date = article.date {
            dateLabel.text = TimeDifferenceStringFromDate(date) + " "
        } else {
            dateLabel.text = ""
        }
        dateLabel.text = dateLabel.text! + "在读"
        articleDetailLabel.text = article.body
        articleViewCountLabel.text = "\(article.viewCount ?? 0)"
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}