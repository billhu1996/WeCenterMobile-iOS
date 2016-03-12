//
//  LoginVC.swift
//  WeCenterMobile
//
//  Created by GaoMing on 16/2/22.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import UIKit
import QRCodeReaderViewController
import UMSocial
import SocialWechat

class LoginVC: UIViewController, QRCodeReaderDelegate {
    
    @IBOutlet weak var weiXinLoginButton: UIButton!
    
    var firstAppear = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            firstAppear = false
            User.loginWithCookiesAndCacheInStorage(
                success: {
                    [weak self] user in
                    User.currentUser = user
                    self?.presentMainViewController()
                },
                failure: nil)
        }
    }
    
    @IBAction func login() {
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToWechatSession)
        snsPlatform.loginClickHandler(self, UMSocialControllerService.defaultControllerService(), true, {response in
            if response.responseCode == UMSResponseCodeSuccess {
                
                let snsAccount:UMSocialAccountEntity = UMSocialAccountManager.socialAccountDictionary()[UMShareToWechatSession] as! UMSocialAccountEntity
                print(snsAccount)
                print("username is \(snsAccount.userName), uid is \(snsAccount.usid), token is \(snsAccount.accessToken) url is \(snsAccount.iconURL)")
                User.registerWithEmail("\(snsAccount.usid)@zaidu.com",
                    name: "\(snsAccount.userName)",
                    password: "123456",
                    success: {
                        [weak self] user in
                        User.currentUser = user
                        if let self_ = self {
                            self_.presentMainViewController()
                        }
                    },
                    failure: {
                        [weak self] error in
                        if error.code == 23333 {
                            User.loginWithName("\(snsAccount.usid)@zaidu.com",
                                password: "123456",
                                success: {
                                    [weak self] user in
                                    User.currentUser = user
                                    if let self_ = self {
                                        self_.presentMainViewController()
                                    }
                                },
                                failure: {
                                    [weak self] error in
                                    if let _ = self {
                                        print((error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误")
                                    }
                                })
                        } else {
                            print((error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误")
                        }
                    })
            } else {
                print(response)
            }
        })
    }
    
    @IBAction func register() {
//        User.registerWithEmail("adfad@163.com",
//            name: "nicheng",
//            password: "password",
//            success: {
//                [weak self] user in
//                User.currentUser = user
//                if let self_ = self {
//                    self_.presentMainViewController()
//                }
//            },
//            failure: {
//                [weak self] error in
//                if error.code == 23333 {
//                    print("fasdfasdf")
//                } else {
//                    print((error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误")
//                }
//            })
    }
    
    func presentMainViewController() {
        appDelegate.mainViewController = MainViewController()
        appDelegate.mainViewController.modalTransitionStyle = .CrossDissolve
        presentViewController(appDelegate.mainViewController, animated: true, completion: nil)
    }
    
}
