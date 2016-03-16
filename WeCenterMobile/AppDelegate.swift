//
//  AppDelegate.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/14.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import AFNetworking
import CoreData
import DTCoreText
import DTFoundation
import SinaWeiboSDK
import SVProgressHUD
import UIKit
import WeChatSDK
import UMSocial
import SocialWechat

let userStrings: (String) -> String = {
    return NSLocalizedString($0, tableName: "User", comment: "")
}

let discoveryStrings: (String) -> String = {
    return NSLocalizedString($0, tableName: "Discovery", comment: "")
}

let welcomeStrings: (String) -> String = {
    return NSLocalizedString($0, tableName: "Welcome", comment: "")
}

var appDelegate: AppDelegate {
    return UIApplication.sharedApplication().delegate as! AppDelegate
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var window: UIWindow? = {
        let v = UIWindow(frame: UIScreen.mainScreen().bounds)
        return v
    }()
    
    lazy var loginViewController: LoginVC = {
        let vc = NSBundle.mainBundle().loadNibNamed("LoginVC", owner: nil, options: nil).first as! LoginVC
        return vc
    }()
    
    var cacheFileURL: NSURL {
        let directory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
        let url = directory.URLByAppendingPathComponent("WeCenterMobile.sqlite")
        return url
    }
    
    var mainViewController: MainViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
//        clearCaches()
        UIScrollView.msr_installPanGestureTranslationAdjustmentExtension()
        UIScrollView.msr_installTouchesCancellingExtension()
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        DTAttributedTextContentView.setLayerClass(DTTiledLayerWithoutFade.self)
        SVProgressHUD.setDefaultMaskType(.Gradient)
//        WeiboSDK.registerApp("3758958382")
        WXApi.registerApp("wxb0d4e235d6897257")
        UMSocialData.setAppKey("56e3b4b0e0f55aa2c60011ea")
        UMSocialWechatHandler.setWXAppId("wxb0d4e235d6897257", appSecret: "cf81ec43d54276b1e951e6aa41d145f2", url: "http://we.edustack.org")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTheme", name: CurrentThemeDidChangeNotificationName, object: nil)
        updateTheme()
        window!.rootViewController = loginViewController
        window!.makeKeyAndVisible()
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        try! DataManager.defaultManager!.saveChanges()
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return UMSocialSnsService.handleOpenURL(url, wxApiDelegate: nil) || WXApi.handleOpenURL(url, delegate: nil)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let result = UMSocialSnsService.handleOpenURL(url)
        if result == false {
            //调用其他SDK，例如支付宝SDK等
        }
        return result;
    }
    
    func clearCaches() {
        NetworkManager.clearCookies()
        do {
            try NSFileManager.defaultManager().removeItemAtURL(cacheFileURL)
        } catch _ {
        }
        DataManager.defaultManager = nil
        DataManager.temporaryManager = nil
    }
    
    func updateTheme() {
        let theme = SettingsManager.defaultManager.currentTheme
        mainViewController?.contentViewController.view.backgroundColor = theme.backgroundColorA
        UINavigationBar.appearance().barStyle = theme.navigationBarStyle
        UINavigationBar.appearance().barTintColor = theme.navigationBarTintColor
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = theme.navigationItemColor
    }
    
}
