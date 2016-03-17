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
    @IBOutlet weak var publicedCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .None
    }
    
    func update(user user: User) {
//        print(user)
        self.userAvatarView.wc_updateWithUser(user)
//        userNameLabel.text = user.name
        userSignatureLabel.text = user.signature
        followersCountLabel.text = "\(user.followerCount ?? 0)"
        followingCountLabel.text = "\(user.followingCount ?? 0)"
        publicedCountLabel.text = "\(user.articleCount ?? 0)"
        if user.gender == .Male {
            followingTitleLabel.text = "他的关注"
        }
        if user.gender == .Female {
            followingTitleLabel.text = "她的关注"
        }
        if user.gender == .Secret {
            followingTitleLabel.text = "Ta的关注"
        }
        if let province = user.province {
            userLocationLabel.text = province + (user.city ?? "")
        }
//        self.followButton.hidden = user.isCurrentUser
//        if let following = user.following {
//            self.followButton.setTitle(following ? "已关注" : "关注", forState: .Normal)
//        }
    }
    
}
