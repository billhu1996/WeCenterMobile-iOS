//
//  UserC.swift
//  WeCenterMobile
//
//  Created by GaoMing on 16/2/25.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class UserC: UITableViewCell {
    
    @IBOutlet weak var userAvatarView: MSRRoundedImageView!
//    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSignatureLabel: UILabel!
//    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingTitleLabel: UILabel!
    @IBOutlet weak var followersTitleLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
    }
    
    func update(user user: User) {
        self.userAvatarView.wc_updateWithUser(user)
//        userNameLabel.text = user.name
        userSignatureLabel.text = user.signature
        followersCountLabel.text = "\(user.followerCount ?? 0)"
        followingCountLabel.text = "\(user.followingCount ?? 0)"
        if user.gender == .Male {
            followersTitleLabel.text = "关注他的人"
            followingTitleLabel.text = "他关注的人"
        }
        if user.gender == .Female {
            followersTitleLabel.text = "关注她的人"
            followingTitleLabel.text = "她关注的人"
        }
        if user.gender == .Secret {
            followersTitleLabel.text = "关注Ta的人"
            followingTitleLabel.text = "Ta关注的人"
        }
        userLocationLabel.text = user.province! + "  " + user.city!
//        self.followButton.hidden = user.isCurrentUser
        print(user.following)
        if let following = user.following {
//            self.followButton.setTitle(following ? "已关注" : "关注", forState: .Normal)
        }
    }
    
}
