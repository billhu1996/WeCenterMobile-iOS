//
//  WebViewController.swift
//  WeCenterMobile
//
//  Created by GaoMing on 16/2/22.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIAlertViewDelegate, UIWebViewDelegate {
    
    var requestURL = ""
    var loaded = true;
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var backButton: UIBarButtonItem = UIBarButtonItem.init(title: "返回", style: UIBarButtonItemStyle.Plain, target: self, action: "back")
        self.navigationItem.leftBarButtonItem = backButton;
        self.loaded = false;
        self.view.backgroundColor = UIColor.whiteColor();
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.loaded {
            self.webView.frame = self.view.bounds;
            self.webView.delegate = self;
            self.view.addSubview(self.webView)
            let req: NSURLRequest = NSURLRequest.init(URL: NSURL.init(string: self.requestURL)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData  , timeoutInterval: 20)
            self.webView.loadRequest(req)
            self.loaded = true;
        }
        
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func addToReadingList(sender: AnyObject) {
        var alertView = UIAlertView.init(title: "确认添加到在读列表？", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "添加")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            print("1")
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if self.loaded {
            addToReadingList(self)
        }
    }
    
    @IBAction func comment(sender: AnyObject) {
    }
    
    @IBAction func like(sender: AnyObject) {
    }
}
