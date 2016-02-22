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

class LoginVC: UIViewController, QRCodeReaderDelegate {
    
    @IBOutlet weak var weiXinLoginButton: UIButton!
    
    lazy var qrViewController: QRCodeReaderViewController = {
        //        NSArray *types = @[AVMetadataObjectTypeQRCode];
        //        _reader        = [QRCodeReaderViewController readerWithMetadataObjectTypes:types];
        //
        //        _reader.delegate = self;
        
        let types: Array<String> = ["AVMetadataObjectTypeQRCode"]
        
        var qrViewController = QRCodeReaderViewController.readerWithMetadataObjectTypes(types)
        qrViewController.delegate = self
        return qrViewController
    }()
    
    lazy var webViewController: WebViewController = {
        var webViewController = NSBundle.mainBundle().loadNibNamed("WebViewController", owner: nil, options: nil).first as! WebViewController
        webViewController.requestURL = "http://www.baidu.com/"
        return webViewController
    }()
    
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
                if let _ = self {
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
                if let _ = self {
                    print((error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误")
                }
            })
    }
    
    func presentMainViewController() {
        appDelegate.mainViewController = MainViewController()
        appDelegate.mainViewController.modalTransitionStyle = .CrossDissolve
        presentViewController(appDelegate.mainViewController, animated: true, completion: nil)
    }
    
    @IBAction func qrScan(sender: AnyObject) {
        presentViewController(self.qrViewController, animated: true, completion: nil)
    }
    
    func reader(reader: QRCodeReaderViewController!, didScanResult result: String!) {
        dismissViewControllerAnimated(true) { () -> Void in
            print(result)
            self.presentViewController(self.webViewController, animated: true, completion: nil)
        }
    }
    func readerDidCancel(reader: QRCodeReaderViewController!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
