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
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var articleButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var articleContainerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var articleBody: MSRMultilineLabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var articleView: UIView!
    
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
        articleView.backgroundColor = theme.borderColorA
        containerView.msr_borderColor = theme.borderColorA
        for v in [userButton, articleButton] {
            v.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        }
        for v in [userNameLabel, articleTitleLabel] {
            v.textColor = theme.titleTextColor
        }
    }
    
    func update(action action: Action) {
        let action = action as! ArticlePublishmentAction
        if let url = action.article?.imageURL {
            if let url = NSURL(string: url) {
                detailImageView.setImageWithURLRequest(NSURLRequest(URL: url), placeholderImage: UIImage(named: "User-Follow"), success: {
                    [weak self] request, response, image in
                    if let self_ = self {
                        self_.detailImageView.image = image
                    }
                    }, failure: {
                    [weak self] _, _, _ in
                        if let self_ = self {
                            self_.detailImageView.image = UIImage(named: "User-Follow")
                        }
                        return
                })
            }
            print("image \(url)")
        }
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
        userAvatarView.wc_updateWithUser(action.user)
        setNeedsLayout()
        layoutIfNeeded()
    }
}