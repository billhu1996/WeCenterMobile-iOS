//
//  CommentCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/2/3.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        msr_scrollView?.delaysContentTouches = false
    }
    
    func update(comment comment: Comment) {
        msr_userInfo = comment
        userAvatarView.wc_updateWithUser(comment.user)
        userNameLabel.text = comment.user?.name
        let attributedString = NSMutableAttributedString()
        if comment.atUser?.name != nil {
            attributedString.appendAttributedString(NSAttributedString(
                string: "回复@\(comment.atUser!.name!) ",
                attributes: [
                    NSFontAttributeName: UIFont.boldSystemFontOfSize(15)]))
        }
        attributedString.appendAttributedString(NSAttributedString(
            string: (comment.body ?? ""),
            attributes: [
                NSFontAttributeName: UIFont.systemFontOfSize(15)]))
        bodyLabel.attributedText = attributedString
        if let date = comment.date {
            dateLabel.text = TimeDifferenceStringFromDate(date)
        } else {
            dateLabel.text = ""
        }
        userButton.msr_userInfo = comment.user
        replyButton.msr_userInfo = comment.user
        replyButton.hidden = comment.user?.id == User.currentUser?.id
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
