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
    
    var article: Article = {
        let ret = Article.temporaryObject()
        ret.id = -1
        return ret
    }()
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var firstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = view.bounds;
        webView.delegate = self;
        let hColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        commentButton.msr_setBackgroundImageWithColor(hColor, forState: .Highlighted)
        shareButton.msr_setBackgroundImageWithColor(hColor, forState: .Highlighted)
        addButton.msr_setBackgroundImageWithColor(hColor, forState: .Highlighted)
        likeButton.msr_setBackgroundImageWithColor(hColor, forState: .Highlighted)
        view.addSubview(webView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if firstAppear {
            firstAppear = false
            view.backgroundColor = UIColor.whiteColor();
            let v = NSBundle.mainBundle().loadNibNamed("TitleView", owner: nil, options: nil).first as! TitleView
            v.nameLabel.text = article.user?.name
            v.avatarImage.wc_updateWithUser(article.user)
            v.backgroundColor = UIColor.clearColor()
            navigationItem.titleView = v
            if article.id != -1 {
                reloadData()
                Article.fetch(
                    ID: article.id,
                    success: {
                        [weak self] article in
                        if let self_ = self {
                            self_.article = article
                            self_.reloadData(true)
                        }
                    },
                    failure: {
                        error in
                        print(error)
                        return
                })
            } else {
                reloadData(true)
            }
        }
    }
    
    @IBAction func share(sender: AnyObject) {
        if article.id != -1 {
            let title = article.title!
            let body = article.body!.wc_plainString
            let url = article.url!
            var items = [title, body, NSURL(string: url)!]
            if let image = article.image {
                items.append(image)
            }
            let vc = UIActivityViewController(
                activityItems: items,
                applicationActivities: [WeChatSessionActivity(), WeChatTimelineActivity()])
            showDetailViewController(vc, sender: self)
        } else {
            let ac = UIAlertController(title: "错误", message: "您不能分享未发布的内容。", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func addToReadingList(sender: AnyObject) {
        if article.id != -1 && article.isInReadingList {
            let ac = UIAlertController(title: "文章已经在您的在读列表中", message: "", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        let ac = UIAlertController(title: "确认添加到在读列表？", message: "", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "添加", style: .Default) {
            [weak self] _ in
            if let self_ = self {
                if self_.article.id != -1 && !self_.article.isInReadingList {
                    self_.article.focus(
                        success: {
                            [weak self] in
                            if let self_ = self {
                                self_.reloadData()
                            }
                        },
                        failure: {
                            [weak self] error in
                            let ac = UIAlertController(title: "错误", message: (error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误。", preferredStyle: .Alert)
                            ac.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: nil))
                            self?.presentViewController(ac, animated: true, completion: nil)
                            return
                        })
                } else {
                    self_.publish()
                }
            }
            return
        })
        presentViewController(ac, animated: true, completion: nil)
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
            let vc = CommentListViewController(dataObject: article, editing: true)
            msr_navigationController!.pushViewController(vc, animated: true)
        } else {
            let ac = UIAlertController(title: "错误", message: "您不能对未发布的内容进行评论。", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
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
                    [weak self] error in
                    let ac = UIAlertController(title: "错误", message: (error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "未知错误。", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: nil))
                    self?.presentViewController(ac, animated: true, completion: nil)
                    return
                })
        } else {
            let ac = UIAlertController(title: "错误", message: "您不能对未发布的内容进行评价。", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "好的", style: .Cancel, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    func publish() {
        article.postWithURL(
            success: {
                [weak self] article in
                if let self_ = self {
                    self_.article = article
                    self_.reloadData()
                }
            },
            failure: {
                error in
                print(error)
            })
    }
    
    func reloadData(reloadWebView: Bool = false) {
        if reloadWebView {
            if let url = article.url {
                let request = NSURLRequest(URL: NSURL(string: url)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 60)
                webView.loadRequest(request)
            }
        }
        commentImageView.image = UIImage(named: article.id != -1 ? "WebVCCommentGreen" : "WebVCCommentGray")
        shareImageView.image = UIImage(named: article.id != -1 ? "WebVCShareGreen" : "WebVCShareGray")
        addImageView.image = UIImage(named: article.id != -1 && article.isInReadingList ? "WebVCAddGreen" : "WebVCAddGray")
        likeImageView.image = UIImage(named: article.evaluation == Evaluation.Up && !article.isPublishedByCurrentUser ? "WebVCLikeGreen" : "WebVCLikeGray")
        commentButton.enabled = article.id != -1
        shareButton.enabled = article.id != -1
        likeButton.enabled = article.id != -1
    }
    
}
