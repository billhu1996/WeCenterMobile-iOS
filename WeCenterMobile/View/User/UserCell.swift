//
//  UserCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/4/10.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followStatusLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var articleCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var followActivityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
        userButton.msr_setBackgroundImageWithColor(UIColor.blackColor().colorWithAlphaComponent(0.2), forState: .Highlighted)
    }

    func update(user user: User) {
        userAvatarView.wc_updateWithUser(user)
        userNameLabel.text = user.name
        /// @TODO: [Bug][Back-End] \n!!!
        userSignatureLabel.text = user.signature?.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        articleCountLabel.text = "\(user.articleCount ?? 0)"
        followerCountLabel.text = "\(user.followerCount ?? 0)"
        if let following = user.following {
            followActivityIndicatorView.stopAnimating()
            followButton.tintColor = following ? UIColor.msr_materialGray() : %+0xff911e
            followStatusLabel.text = following ? "已关注" : "加关注"
            followButton.hidden = false
            followStatusLabel.hidden = false
        } else {
            followActivityIndicatorView.startAnimating()
            followButton.hidden = true
            followStatusLabel.hidden = true
        }
        userButton.msr_userInfo = user
        followButton.msr_userInfo = user
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
