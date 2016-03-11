//
//  SearchBarCell.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 16/2/21.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class SearchBarCell: UITableViewCell {

//    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let theme = SettingsManager.defaultManager.currentTheme
//        searchBar.placeholder = "搜索用户和内容"
//        searchBar.barStyle = theme.navigationBarStyle
//        searchBar.keyboardAppearance = theme.keyboardAppearance
        setNeedsLayout()
        layoutIfNeeded()
    }
}
