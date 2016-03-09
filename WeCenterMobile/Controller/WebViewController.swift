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
    var published = false
    var articleID = -1
    var evaluate: Evaluation = Evaluation.None
//    var superViewController: UIViewController
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Navigation-Back"), style: .Plain, target: nil, action: "didPressBackButton")
        self.loaded = false;
        self.view.backgroundColor = UIColor.whiteColor();
    }
    
    func didPressBackButton() {
        return dismissViewControllerAnimated(true, completion: nil)
    }
    
//    init(superViewController: UIViewController) {
//        self.superViewController = superViewController
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.loaded {
            self.webView.frame = self.view.bounds;
            self.webView.delegate = self;
            self.view.addSubview(self.webView)
            let req: NSURLRequest = NSURLRequest.init(URL: NSURL.init(string: self.requestURL)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData  , timeoutInterval: 60)
            self.webView.loadRequest(req)
            self.loaded = true;
        }
        
    }
    
    func back() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func addToReadingList(sender: AnyObject) {
        let alertView = UIAlertView(title: "确认添加到在读列表？", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "添加")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.publish(1)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webView.loading {
            return
        }
        addToReadingList(self)
    }
    
    @IBAction func comment(sender: AnyObject) {
        if self.published {
            let article = Article.temporaryObject()
            article.id = self.articleID
            let vc = CommentListViewController(dataObject: article, editing: true)
            self.msr_navigationController!.pushViewController(vc, animated: true)
        }
        self.publish(2)
    }
    
    @IBAction func like(sender: AnyObject) {
        if self.published {
            let article = Article.temporaryObject()
            article.id = self.articleID
            if self.evaluate == .None {
                article.evaluate(value: .Up,
                    success: {
                        [weak self] in
                        if let self_ = self {
                            self_.evaluate = .Up
                        }
                    },
                    failure: {
                        error in
                        print(error)
                    })
            }
            if self.evaluate == .Up {
                article.evaluate(value: .None,
                    success: {
                        [weak self] in
                        if let self_ = self {
                            self_.evaluate = .None
                        }
                    },
                    failure: {
                        error in
                        print(error)
                })
            }
        }
        self.publish(3)
    }
    
    func publish(mode: Int) {
        if self.published {
            return
        }
        let article = Article.temporaryObject()
        article.url = self.requestURL
        article.postWithURL(
            success: {
                [weak self] articleID in
                if mode == 1 {
                    let alertView = UIAlertView(title: "发布成功", message: "", delegate: self, cancelButtonTitle: "好的")
                    alertView.show()
                }
                if let self_ = self {
                    self_.published = true
                    self_.articleID = articleID
                    if mode == 2 {
                        let article = Article.temporaryObject()
                        article.id = self_.articleID
                        let vc = CommentListViewController(dataObject: article, editing: true)
                        self_.msr_navigationController!.pushViewController(vc, animated: true)
                    }
                    if mode == 3 {
                        let article = Article.temporaryObject()
                        article.id = self_.articleID
                        if self_.evaluate == .None {
                            article.evaluate(value: .Up,
                                success: {
                                    [weak self] in
                                    if let self_ = self {
                                        self_.evaluate = .Up
                                    }
                                },
                                failure: {
                                    error in
                                    print(error)
                            })
                        }
                        if self_.evaluate == .Up {
                            article.evaluate(value: .None,
                                success: {
                                    [weak self] in
                                    if let self_ = self {
                                        self_.evaluate = .None
                                    }
                                },
                                failure: {
                                    error in
                                    print(error)
                            })
                        }
                    }
                }
            },
            failure: {
                error in
                print(error)
        })
    }
}
