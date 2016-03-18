//
//  WebViewController.swift
//  WeCenterMobile
//
//  Created by GaoMing on 16/2/22.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import UIKit
import WeChatSDK
import UMSocial
import SocialWechat

class WebViewController: UIViewController, UIAlertViewDelegate, UIWebViewDelegate {
    
    var requestURL = ""
    var loaded = true
    var userName = ""
    var article: Article = {
        let ret = Article.temporaryObject()
        ret.id = -1
        return ret
    }()
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let item = UIBarButtonItem(image: UIImage(named: "WebVCShareGreen"), style: .Plain, target: self, action: "share:")
        navigationItem.rightBarButtonItem = item
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loaded = false;
        view.backgroundColor = UIColor.whiteColor();
        let v = NSBundle.mainBundle().loadNibNamed("TitleView", owner: nil, options: nil).first as! TitleView
        v.nameLabel.text = article.user?.name
        v.avatarImage.wc_updateWithUser(article.user)
        v.backgroundColor = UIColor.clearColor()
        navigationItem.titleView = v
        reloadData()
    }
    
    func share(sender: AnyObject) {
        print(article.title!)
        let title = article.title!
        let body = article.body!.wc_plainString
        let url = requestURL
        var items = [title, body, NSURL(string: url)!]
        if let image = article.image {
            items.append(image)
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: [WeChatSessionActivity(), WeChatTimelineActivity()])
        showDetailViewController(vc, sender: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loaded {
            webView.frame = view.bounds;
            webView.delegate = self;
            view.addSubview(webView)
            let req: NSURLRequest = NSURLRequest.init(URL: NSURL(string: requestURL)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 60)
            webView.loadRequest(req)
            loaded = true;
        }
        
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func addToReadingList(sender: AnyObject) {
        let alertView = UIAlertView(title: "确认添加到在读列表？", message: "", delegate: self, cancelButtonTitle: "取消", otherButtonTitles: "添加")
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            publish(1)
        }
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if webView.loading {
            return
        }
        if article.id == -1 {
            addToReadingList(self)
        }
    }
    
    @IBAction func comment(sender: AnyObject) {
        if article.id != -1 {
            let temporaryArticle = Article.temporaryObject()
            temporaryArticle.id = article.id
            temporaryArticle.title = article.title
            temporaryArticle.agreementCount = article.agreementCount
            let vc = CommentListViewController(dataObject: article, editing: true)
            msr_navigationController!.pushViewController(vc, animated: true)
        }
        publish(2)
    }
    
    @IBAction func like(sender: AnyObject) {
        if article.id != -1 {
            article.evaluate(value: article.evaluation == .Up ? .None : .Up,
                success: {
                    [weak self] in
                    if let self_ = self {
                        self_.reloadData()
                    }
                },
                failure: {
                    error in
                    print(error)
                })
        }
        publish(3)
    }
    
    func publish(mode: Int) {
        let article = Article.temporaryObject()
        article.url = requestURL
        article.postWithURL(
            success: {
                [weak self] article in
                if let self_ = self {
                    if mode == 1 {
                        let alertView = UIAlertView(title: "发布成功", message: "", delegate: self, cancelButtonTitle: "好的")
                        alertView.show()
                        self_.reloadData()
                    }
                    if mode == 2 {
                        let article = Article.temporaryObject()
                        article.id = self_.article.id
                        article.title = self_.article.title
                        article.agreementCount = self_.article.agreementCount
                        let vc = CommentListViewController(dataObject: article, editing: true)
                        self_.msr_navigationController!.pushViewController(vc, animated: true)
                        self_.reloadData()
                    }
                    if mode == 3 {
                        article.evaluate(value: article.evaluation == .Up ? .None : .Up,
                            success: {
                                [weak self] in
                                if let self_ = self {
                                    self_.reloadData()
                                }
                            },
                            failure: {
                                error in
                                print(error)
                        })
                    }
                }
            },
            failure: {
                error in
                print(error)
            })
    }
    
    func reloadData() {
        if article.id != -1 {
            addButton.setImage(UIImage(named: "WebVCAddGreen"), forState: .Normal)
        } else {
            addButton.setImage(UIImage(named: "WebVCAddGray"), forState: .Normal)
        }
        if article.evaluation == .None {
            likeButton.setImage(UIImage(named: "WebVCLikeGray"), forState: .Normal)
        } else {
            likeButton.setImage(UIImage(named: "WebVCLikeGreen"), forState: .Normal)
        }
//        if articleID != -1 {
//            commentLabel.text = "\(article.)"
//        }
    }
}
