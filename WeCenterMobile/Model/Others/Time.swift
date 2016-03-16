//
//  Time.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 16/3/16.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation

func TimeDifferenceStringFromDate(date: NSDate) -> String {
    let diff = Int(-date.timeIntervalSinceNow)
    let seconds = diff
    let minutes = seconds / 60
    let hours = minutes / 60
    let days = hours / 24
    let months = days / 30
    let years = months / 12
    if seconds < 60 {
        return "\(seconds)秒前"
    }
    if minutes < 60 {
        return "\(minutes)分钟前"
    }
    if hours < 24 {
        return "\(hours)小时前"
    }
    if days < 30 {
        return "\(days)天前"
    }
    if months < 12 {
        return "\(months)月前"
    }
    return "\(years)年前"
}
