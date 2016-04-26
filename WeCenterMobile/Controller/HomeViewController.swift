//
//  HomeViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/12/24.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import MJRefresh
import UIKit
import QRCodeReaderViewController

@objc protocol ActionCell: class {
    optional var userButton: UIButton! { get }
    optional var questionButton: UIButton! { get }
    optional var answerButton: UIButton! { get }
    optional var articleButton: UIButton! { get }
    optional var commentButton: UIButton! { get }
    func update(action action: Action)
}

extension AnswerActionCell: ActionCell {}
extension QuestionPublishmentActionCell: ActionCell {}
extension QuestionFocusingActionCell: ActionCell {}
extension AnswerAgreementActionCell: ActionCell {}
extension ArticlePublishmentActionCell: ActionCell {}
extension ArticleAgreementActionCell: ActionCell {}
extension ArticleCommentaryActionCell: ActionCell {}

class HomeViewController: UITableViewController, PublishmentViewControllerDelegate, QRCodeReaderDelegate {
    
    lazy var searchBarCell: SearchBarCell = {
        let c = NSBundle.mainBundle().loadNibNamed("SearchBarCell", owner: nil, options: nil).first as! SearchBarCell
        c.searchButton.addTarget(nil, action: #selector(HomeViewController.didPressSearchButton(_:)), forControlEvents: .TouchUpInside)
        return c
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "首页"
        label.textColor = .whiteColor()
        label.font = UIFont.boldSystemFontOfSize(17)
        label.sizeToFit()
        return label
    }()
    let count = 20
    var page = 1
    var shouldReloadAfterLoadingMore = true
    
    let user: User
    var actions = [Action]()
    
    let actionTypes: [Action.Type] = [ArticlePublishmentAction.self, ArticleAgreementAction.self, ArticleCommentaryAction.self]
    let identifiers = ["ArticlePublishmentActionCell", "ArticleAgreementActionCell", "ArticleCommentaryActionCell"]
    let nibNames = ["ArticlePublishmentActionCell", "ArticleAgreementActionCell", "ArticleCommentaryActionCell"]
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        title = "首页" // Needs localization
        msr_navigationBar!.msr_shadowImageView?.hidden = true
        navigationItem.titleView = titleLabel
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Navigation-Root"), style: .Plain, target: self, action: #selector(HomeViewController.showSidebar))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Navigation-QRCode"), style: .Plain, target: self, action: #selector(HomeViewController.showQRCodeViewController))
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        tableView.indicatorStyle = theme.scrollViewIndicatorStyle
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.wc_addRefreshingHeaderWithTarget(self, action: #selector(HomeViewController.refresh))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header.beginRefreshing()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, min(page * count, actions.count)][section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            return searchBarCell
        }
        let action = actions[indexPath.row]
        if let index = (actionTypes.map { action.classForCoder === $0 }).indexOf(true) {
            let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[index], forIndexPath: indexPath) as! ActionCell
            cell.update(action: action)
            cell.userButton?.addTarget(self, action: #selector(HomeViewController.didPressUserButton(_:)), forControlEvents: .TouchUpInside)
            cell.articleButton?.addTarget(self, action: #selector(HomeViewController.didPressArticleButton(_:)), forControlEvents: .TouchUpInside)
            cell.commentButton?.addTarget(self, action: #selector(HomeViewController.didPressCommentButton(_:)), forControlEvents: .TouchUpInside)
            return cell as! UITableViewCell
        } else {
            return UITableViewCell() // Needs specification
        }
        
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
    func publishmentViewControllerDidSuccessfullyPublishDataObject(publishmentViewController: PublishmentViewController) {
        tableView.mj_header.beginRefreshing()
    }
    
    func didPressPublishButton() {
        let ac = UIAlertController(title: "发布什么？", message: "选择发布的内容种类。", preferredStyle: .ActionSheet)
        let presentPublishmentViewController: (String, PublishmentViewControllerPresentable) -> Void = {
            [weak self] title, object in
            let vc = NSBundle.mainBundle().loadNibNamed("PublishmentViewControllerA", owner: nil, options: nil).first as! PublishmentViewController
            vc.delegate = self
            vc.dataObject = object
            vc.headerLabel.text = title
            self?.presentViewController(vc, animated: true, completion: nil)
        }
        ac.addAction(UIAlertAction(title: "问题", style: .Default) {
            action in
            presentPublishmentViewController("发布问题", Question.temporaryObject())
        })
        ac.addAction(UIAlertAction(title: "文章", style: .Default) {
            action in
            presentPublishmentViewController("发布文章", Article.temporaryObject())
        })
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    var qrViewController: QRCodeReaderViewController! = nil
    
    func showQRCodeViewController() {
        let types = ["AVMetadataObjectTypeQRCode"]
        qrViewController = QRCodeReaderViewController.readerWithMetadataObjectTypes(types)
        qrViewController.delegate = self
        presentViewController(qrViewController, animated: true, completion: nil)
    }
    
    func reader(reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.dismissViewControllerAnimated(true) {
            [weak self] in
            if let self_ = self {
                let article = Article.temporaryObject()
                let webViewController = NSBundle.mainBundle().loadNibNamed("WebViewController", owner: nil, options: nil).first as! WebViewController
                article.id = -1
                article.url = result
                webViewController.article = article
                self_.msr_navigationController!.pushViewController(webViewController, animated: true)
            }
        }
    }
    
    func readerDidCancel(reader: QRCodeReaderViewController!) {
        reader.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserVC(user: user), animated: true)
        }
    }
    
    func didPressArticleButton(sender: UIButton) {
        if let article = sender.msr_userInfo as? Article {
            if let _ = article.url {
                let webViewController = NSBundle.mainBundle().loadNibNamed("WebViewController", owner: nil, options: nil).first as! WebViewController
                webViewController.article = article
                msr_navigationController!.pushViewController(webViewController, animated: true)
            } else {
                msr_navigationController!.pushViewController(ArticleViewController(dataObject: article), animated: true)
            }
        }
    }
    
    func didPressCommentButton(sender: UIButton) {
        if let article = (sender.msr_userInfo as? ArticleComment)?.article {
            msr_navigationController!.pushViewController(CommentListViewController(dataObject: article), animated: true)
        } else if let answer = (sender.msr_userInfo as? AnswerComment)?.answer {
            msr_navigationController!.pushViewController(CommentListViewController(dataObject: answer), animated: true)
        }
    }
    
    func didPressSearchButton(sender: UIButton) {
        msr_navigationController!.pushViewController(SearchViewController(nibName: nil, bundle: nil), animated: false)
    }
    
    internal func refresh() {
        shouldReloadAfterLoadingMore = false
        tableView.mj_footer?.endRefreshing()
        User.fetchActions(
            page: 1,
            count: count,
            includingAgreements: true,
            userID: nil,
            success: {
                [weak self] actions in
                if let self_ = self {
                    self_.page = 1
                    self_.actions = actions
                    self_.tableView.reloadData()
                    self_.tableView.mj_header.endRefreshing()
                    if self_.tableView.mj_footer == nil {
                        self_.tableView.wc_addRefreshingFooterWithTarget(self_, action: #selector(HomeViewController.loadMore))
                    }
                }
            },
            failure: {
                [weak self] error in
                self?.tableView.mj_header.endRefreshing()
                return
            })
    }
    
    internal func loadMore() {
        if tableView.mj_header.isRefreshing() {
            tableView.mj_footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        User.fetchActions(
            page: page + 1,
            count: count,
            includingAgreements: true,
            userID: nil,
            success: {
                [weak self] actions in
                if let self_ = self {
                    if self_.shouldReloadAfterLoadingMore {
                        ++self_.page
                        self_.actions.appendContentsOf(actions)
                        self_.tableView.reloadData()
                    }
                    self_.tableView.mj_footer.endRefreshing()
                }
            },
            failure: {
                [weak self] error in
                self?.tableView.mj_footer.endRefreshing()
                return
            })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
}