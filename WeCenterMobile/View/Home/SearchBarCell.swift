//
//  SearchBarCell.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 16/2/21.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import UIKit

class SearchBarCell: UITableViewCell {

    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchButton.msr_setBackgroundImageWithColor(contentView.backgroundColor!.colorWithAlphaComponent(0.5), forState: .Highlighted)
        searchImageView.tintColor = %+0x033649
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
