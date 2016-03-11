//
//  ArticlePublishmentActionCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/29.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticlePublishmentActionCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
//    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var articleContainerView: UIView!
//    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var articleBody: MSRMultilineLabel!
    @IBOutlet weak var detailImageView: UIImageView!
    
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
        containerView.msr_borderColor = theme.borderColorA
//        separator.backgroundColor = theme.borderColorB
        for v in [userButton, articleButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userNameLabel, articleTitleLabel] {
            v.textColor = theme.titleTextColor
        }
//        typeLabel.textColor = theme.subtitleTextColor
    }
    
    func update(action action: Action) {
        let action = action as! ArticlePublishmentAction
        userAvatarView.wc_updateWithUser(action.user)
        userNameLabel.text = action.user?.name ?? "匿名用户"
        articleBody.text = action.article?.body
        
        if let date = action.article?.date {
            dateLabel.text = dateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
        if let URL = action.article?.imageURL {
            let url = NSURL(string: URL)
            userAvatarView.setImageWithURL(url, placeholderImage: nil)
        }
        articleTitleLabel.text = action.article!.title
        userButton.msr_userInfo = action.user
        articleButton.msr_userInfo = action.article
        setNeedsLayout()
        layoutIfNeeded()
    }
}