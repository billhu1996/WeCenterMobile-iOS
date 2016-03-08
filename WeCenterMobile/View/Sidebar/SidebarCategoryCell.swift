//
//  SidebarCategoryCell.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 15/3/31.
//  Copyright (c) 2015年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class SidebarCategoryCell: UITableViewCell {
    
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var markCountLabel: UILabel!
    @IBOutlet weak var markExplanationLabel: UILabel!
    
    var category: SidebarCategory?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.greenColor()
        self.selectedBackgroundView = view
        msr_scrollView?.delaysContentTouches = false
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func update(category category: SidebarCategory) {
        self.category = category
        categoryImageView.image = imageFromSidebarCategory(category)
        categoryTitleLabel.text = localizedStringFromSidebarCategory(category)
        if category == .ReadingList {
            markCountLabel.alpha = 1
            markExplanationLabel.alpha = 1
        }
        updateTheme()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func updateTheme() {
        let theme = SettingsManager.defaultManager.currentTheme
        categoryImageView.tintColor = theme.titleTextColor
        categoryTitleLabel.textColor = theme.titleTextColor
//        selectedBackgroundView!.backgroundColor = theme.highlightColor
    }
    
    override func prepareForReuse() {
        category = nil
    }
    
}
