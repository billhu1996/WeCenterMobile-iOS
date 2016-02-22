//
//  LoginVC.swift
//  WeCenterMobile
//
//  Created by GaoMing on 16/2/22.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var weiXinLoginButton: UIButton!
    
    @IBAction func login() {
        User.loginWithName("congmingdehuli666@163.com",
            password: "qwerty",
            success: {
                [weak self] user in
                User.currentUser = user
                if let self_ = self {
                    self_.presentMainViewController()
                }
            },
            failure: {
                [weak self] error in
                if let self_ = self {
                    print((error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误")
                }
            })
    }
    
    @IBAction func register() {
        User.registerWithEmail("adfad@163.com",
            name: "nicheng",
            password: "password",
            success: {
                [weak self] user in
                User.currentUser = user
                if let self_ = self {
                    self_.presentMainViewController()
                }
            },
            failure: {
                [weak self] error in
                if let self_ = self {
                    print((error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误")
                }
            })
    }
    
    func presentMainViewController() {
        appDelegate.mainViewController = MainViewController()
        appDelegate.mainViewController.modalTransitionStyle = .CrossDissolve
        presentViewController(appDelegate.mainViewController, animated: true, completion: nil)
    }
    
    
}
