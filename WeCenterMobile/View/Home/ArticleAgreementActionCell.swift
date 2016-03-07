
//
//  ArticleAgreementActionCell.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 16/3/6.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class ArticleAgreementActionCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var articleContainerView: UIView!
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: MSRMultilineLabel!
    @IBOutlet weak var articleBodyLabel: MSRMultilineLabel!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var separator: UIView!
    
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
        separator.backgroundColor = theme.borderColorA
        for v in [userButton, articleButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userNameLabel, articleTitleLabel] {
            v.textColor = theme.titleTextColor
        }
    }
    
    func update(action action: Action) {
        let action = action as! ArticleAgreementAction
        userAvatarView.wc_updateWithUser(action.user)
        userNameLabel.text = action.user?.name ?? "匿名用户"
        if let date = action.article?.date {
                        dateLabel.text = dateFormatter.stringFromDate(date)
        } else {
            dateLabel.text = ""
        }
        if let url = action.article?.imageURL {
            detailImageView.setImageWithURL(NSURL(string: url), placeholderImage: nil)
        } else {
            print(action.article?.imageURL)
        }
            
        articleTitleLabel.text = action.article!.title
        articleBodyLabel.text = action.article!.body
        userButton.msr_userInfo = action.user
        articleButton.msr_userInfo = action.article
        setNeedsLayout()
        layoutIfNeeded()
    }
}
