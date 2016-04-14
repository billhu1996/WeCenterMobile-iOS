//
//  LoginVC.swift
//  WeCenterMobile
//
//  Created by GaoMing on 16/2/22.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import UIKit
import PICollectionPageView
import QRCodeReaderViewController
import UMSocial
import SocialWechat

class LoginVC: UIViewController, QRCodeReaderDelegate, PICollectionPageViewDelegate, PICollectionPageViewDataSource {
    
    @IBOutlet weak var pageView: PICollectionPageView!
    @IBOutlet weak var loginButton: UIButton!
    
    let PageViewCellIdentifier = "PageViewCellIdentifier"
    
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageView.delegate = self
        pageView.dataSource = self
        pageView.registerNib(UINib(nibName: "PageViewCell", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: PageViewCellIdentifier)
    }
    
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
                failure: {
                    error in
                    print(error)
                    return
                })
        }
    }
    
    @IBAction func login() {
        let snsPlatform = UMSocialSnsPlatformManager.getSocialPlatformWithName(UMShareToWechatSession)
        snsPlatform.loginClickHandler(self, UMSocialControllerService.defaultControllerService(), true, {
            response in
            if response.responseCode == UMSResponseCodeSuccess {
                let snsAccount: UMSocialAccountEntity = UMSocialAccountManager.socialAccountDictionary()[UMShareToWechatSession] as! UMSocialAccountEntity
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
                                avatarURL: snsAccount.iconURL,
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
    
    func presentMainViewController() {
        appDelegate.mainViewController = MainViewController()
        appDelegate.mainViewController.modalTransitionStyle = .CrossDissolve
        presentViewController(appDelegate.mainViewController, animated: true, completion: nil)
    }
    
    func numberOfPageInPageView(pageView: PICollectionPageView!) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = pageView.dequeueReusableCellWithReuseIdentifier(PageViewCellIdentifier, forIndexPath: indexPath) as! PageViewCell
        cell.imageView.image = indexPath.row < 4 ? UIImage(named: "Login-Welcome-\(indexPath.row + 1)") : nil
        return cell
    }
    
    func pageViewCurrentIndexDidChanged(pageView: PICollectionPageView!) {
        if pageView.currentPageIndex == 4 {
            UIView.animateWithDuration(0.5) {
                [weak self] in
                if let self_ = self {
                    self_.pageView.alpha = 0
                }
            }
        }
    }
    
}
