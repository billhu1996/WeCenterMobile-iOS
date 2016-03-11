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

class UserVC: UITableViewController {
    var user: User
    let count = 20
    var page = 1
    var shouldReloadAfterLoadingMore = true
    
    var actions = [Action]()
    
    let actionTypes: [Action.Type] = [AnswerAction.self, QuestionPublishmentAction.self, QuestionFocusingAction.self, AnswerAgreementAction.self, ArticlePublishmentAction.self, ArticleAgreementAction.self, ArticleCommentaryAction.self]
    let identifiers = ["AnswerActionCell", "QuestionPublishmentActionCell", "QuestionFocusingActionCell", "AnswerAgreementActionCell", "ArticlePublishmentActionCell", "ArticleAgreementActionCell", "ArticleCommentaryActionCell"]
    let nibNames = ["AnswerActionCell", "QuestionPublishmentActionCell", "QuestionFocusingActionCell", "AnswerAgreementActionCell", "ArticlePublishmentActionCell", "ArticleAgreementActionCell", "ArticleCommentaryActionCell"]
    
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
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        tableView.mj_header.beginRefreshing()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + min(page * count, actions.count)
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
//            self.userCell.followButton.addTarget(self, action: "toggleFollow:", forControlEvents: .TouchUpInside)
            return self.userCell
        } else {
            let action = actions[indexPath.row - 1]
            if let index = (actionTypes.map { action.classForCoder === $0 }).indexOf(true) {
                let cell = tableView.dequeueReusableCellWithIdentifier(identifiers[index], forIndexPath: indexPath) as! ActionCell
                cell.update(action: action)
                cell.userButton?.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
                cell.questionButton?.addTarget(self, action: "didPressQuestionButton:", forControlEvents: .TouchUpInside)
                cell.answerButton?.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
                cell.articleButton?.addTarget(self, action: "didPressArticleButton:", forControlEvents: .TouchUpInside)
                cell.commentButton?.addTarget(self, action: "didPressCommentButton:", forControlEvents: .TouchUpInside)
                return cell as! UITableViewCell
            } else {
                return UITableViewCell() // Needs specification
            }
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else {
            return UITableViewAutomaticDimension
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func refresh() {
        User.fetch(ID: user.id,
            success: {
                [weak self] user in
                self?.user = user
                self?.reloadData()
                self?.user.fetchAvatar(
                    forced: true,
                    success: {
                        self?.reloadData()
                    },
                    failure: {
                        [weak self] error in
                        print(error)
                        return
                    })
                return
            },
            failure: {
                [weak self] error in
                print(error)
                return
            })
        shouldReloadAfterLoadingMore = false
        tableView.mj_footer?.endRefreshing()
        user.fetchPublishedActions(
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
        self.navigationController?.title = self.user.name
        self.userCell.update(user: self.user)
        self.tableView.reloadData()
    }
    
    func toggleFollow(sender: UIButton) {
        user.toggleFollow(
            success: {
                self.refresh()
                return
            },
            failure: {
                [weak self] error in
                print(error)
                return
            })
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
    
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserVC(user: user), animated: true)
        }
    }
    
    func didPressQuestionButton(sender: UIButton) {
        if let question = sender.msr_userInfo as? Question {
            msr_navigationController!.pushViewController(QuestionViewController(question: question), animated: true)
        }
    }
    
    func didPressAnswerButton(sender: UIButton) {
        if let answer = sender.msr_userInfo as? Answer {
            msr_navigationController!.pushViewController(ArticleViewController(dataObject: answer), animated: true)
        }
    }
    
    func didPressArticleButton(sender: UIButton) {
        if let article = sender.msr_userInfo as? Article {
            msr_navigationController!.pushViewController(ArticleAnswerViewController(dataObject: article), animated: true)
        }
    }
    
    func didPressCommentButton(sender: UIButton) {
        if let article = (sender.msr_userInfo as? ArticleComment)?.article {
            msr_navigationController!.pushViewController(CommentListViewController(dataObject: article), animated: true)
        } else if let answer = (sender.msr_userInfo as? AnswerComment)?.answer {
            msr_navigationController!.pushViewController(CommentListViewController(dataObject: answer), animated: true)
        }
    }
}

