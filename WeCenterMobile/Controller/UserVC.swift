//
//  UserVC.swift
//  WeCenterMobile
//
//  Created by GaoMing on 16/2/23.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import MJRefresh
import UIKit

@objc protocol UserActionCell: class {
    optional var articleButton: UIButton! { get }
    func update(action action: Action)
}

extension UserArticlePublishmentActionCell: UserActionCell {}
extension UserArticleAgreementActionCell: UserActionCell {}
extension UserArticleCommentaryActionCell: UserActionCell {}

class UserVC: UITableViewController {
    
    var user: User
    let count = 20
    var page = 1
    var shouldReloadAfterLoadingMore = true
    
    lazy var followButtonItem: UIBarButtonItem = {
        [weak self] in
        let item = UIBarButtonItem(title: "加关注", style: .Plain, target: self, action: "toggleFollow")
        return item
    }()
    
    lazy var logoutButtonItem: UIBarButtonItem = {
        [weak self] in
        let item = UIBarButtonItem(title: "注销", style: .Plain, target: self, action: "logout")
        return item
    }()
    
    var actions = [Action]()
    
    let actionTypes: [Action.Type] = [ArticlePublishmentAction.self, ArticleAgreementAction.self, ArticleCommentaryAction.self]
    let identifiers = ["UserArticlePublishmentActionCell", "UserArticleAgreementActionCell", "UserArticleCommentaryActionCell"]
    let nibNames = ["UserArticlePublishmentActionCell", "UserArticleAgreementActionCell", "UserArticleCommentaryActionCell"]
    
    lazy var userCell: UserC = {
        var cell: UserC = NSBundle.mainBundle().loadNibNamed("UserC", owner: nil, options: nil).first as! UserC
        return cell
    }()
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        for i in 0..<nibNames.count {
            tableView.registerNib(UINib(nibName: nibNames[i], bundle: NSBundle.mainBundle()), forCellReuseIdentifier: identifiers[i])
        }
        view.backgroundColor = %+0xf5f2ed
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        tableView.mj_header.beginRefreshing()
        navigationItem.rightBarButtonItem = user.id == User.currentUser?.id ? logoutButtonItem : followButtonItem
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, min(page * count, actions.count)][section]
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return self.userCell
        } else {
            let action = actions[indexPath.row]
            if let index = (actionTypes.map { action.classForCoder === $0 }).indexOf(true) {
                let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[index], forIndexPath: indexPath) as! UserActionCell
                cell.update(action: action)
                cell.articleButton?.addTarget(self, action: "didPressArticleButton:", forControlEvents: .TouchUpInside)
                return cell as! UITableViewCell
            } else {
                return UITableViewCell() // Needs specification
            }
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func refresh() {
        User.fetch(ID: user.id,
            success: {
                [weak self] user in
                if let self_ = self {
                    self_.user = user
                    self_.reloadData()
                    self_.user.fetchAvatar(
                        forced: true,
                        success: {
                            self_.reloadData()
                        },
                        failure: {
                            error in
                            print(error)
                            return
                        })
                }
                return
            },
            failure: {
                error in
                print(error)
                return
            })
        shouldReloadAfterLoadingMore = false
        tableView.mj_footer?.endRefreshing()
        user.fetchRelatedActions(
            page: 1,
            count: count,
            success: {
                [weak self] actions in
                if let self_ = self {
                    self_.page = 1
                    self_.actions = actions
                    self_.tableView.reloadData()
                    self_.tableView.mj_header.endRefreshing()
                    if self_.tableView.mj_footer == nil {
                        self_.tableView.wc_addRefreshingFooterWithTarget(self_, action: "loadMore")
                    }
                }
            },
            failure: {
                [weak self] error in
                self?.tableView.mj_header.endRefreshing()
                return
            })
    }
    func reloadData() {
        self.title = self.user.name
        if let following = user.following {
            self.followButtonItem.title = following ? "已关注" : "加关注"
        }
        self.userCell.update(user: self.user)
        self.tableView.reloadData()
    }
    
    func toggleFollow() {
        user.toggleFollow(
            success: {
                self.refresh()
                return
            },
            failure: {
                error in
                print(error)
                return
            })
    }
    func logout() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    internal func loadMore() {
        if tableView.mj_header.isRefreshing() {
            tableView.mj_footer.endRefreshing()
            return
        }
        shouldReloadAfterLoadingMore = true
        user.fetchRelatedActions(
            page: page + 1,
            count: count,
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
    
    func didPressArticleButton(sender: UIButton) {
        if let article = sender.msr_userInfo as? Article {
            if article.url != nil {
                let webViewController = NSBundle.mainBundle().loadNibNamed("WebViewController", owner: nil, options: nil).first as! WebViewController
                webViewController.article = article
                msr_navigationController!.pushViewController(webViewController, animated: true)
            } else {
                msr_navigationController!.pushViewController(ArticleViewController(dataObject: article), animated: true)
            }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
    
}

