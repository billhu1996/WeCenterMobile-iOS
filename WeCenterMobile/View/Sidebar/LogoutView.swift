//
//  LogoutView.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 16/3/8.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class LogoutView: UIView {
    
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let theme = SettingsManager.defaultManager.currentTheme
        settingButton.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        logoutButton.msr_setBackgroundImageWithColor(theme.highlightColor, forState: .Highlighted)
        
    }
}
