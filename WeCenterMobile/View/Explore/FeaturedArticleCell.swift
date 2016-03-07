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
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var articleTagLabel: UILabel!
    @IBOutlet weak var articleUserButton: UIButton!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var containerView: UIView!
//    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var articleContainerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var articleDetailLabel: MSRMultilineLabel!
    
    lazy var dateFormatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeZone = NSTimeZone.localTimeZone()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        let theme = SettingsManager.defaultManager.currentTheme
        for v in [userContainerView, articleContainerView] {
            v.backgroundColor = theme.backgroundColorB
        }
//        badgeLabel.backgroundColor = theme.backgroundColorA
        for v in [containerView] {
            v.msr_borderColor = theme.borderColorA
        }
        separator.backgroundColor = theme.borderColorA
        for v in [articleUserButton, articleButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userNameLabel, articleTitleLabel] {
            v.textColor = theme.titleTextColor
        }
//        badgeLabel.textColor = theme.footnoteTextColor
    }
    
    func update(object object: FeaturedObject) {
        let object = object as! FeaturedArticle
        let article = object.article!
        if let url = article.imageURL {
            detailImageView.setImageWithURL(NSURL(string: url))
        }
        userAvatarView.wc_updateWithUser(article.user)
        userNameLabel.text = article.user?.name ?? "匿名用户"
        articleTitleLabel.text = article.title
        articleButton.msr_userInfo = article
        articleUserButton.msr_userInfo = article.user
        if let date = object.article?.date {
            dateLabel.text = dateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
        articleDetailLabel.text = object.article?.body
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}