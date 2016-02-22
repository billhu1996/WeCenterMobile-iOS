//
//  WebViewController.swift
//  WeCenterMobile
//
//  Created by GaoMing on 16/2/22.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController {
    
    var requestURL = ""
    var loaded = true;
    @IBOutlet weak var webView: UIWebView!
    
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
            self.view.addSubview(self.webView)
            let req: NSURLRequest = NSURLRequest.init(URL: NSURL.init(string: self.requestURL)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData  , timeoutInterval: 20)
            self.webView.loadRequest(req)
            self.loaded = true;
        }
        
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
