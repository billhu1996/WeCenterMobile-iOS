//
//  CommetListViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/10/4.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import MJRefresh
import SVProgressHUD
import UIKit

protocol CommentListViewControllerPresentable {
    var commentsForCommentListViewController: Set<Comment> { get }
    func fetchCommentsForCommentListViewController(success success: (([Comment]) -> Void)?, failure: ((NSError) -> Void)?)
    func temporaryComment() -> Comment
}

extension Answer: CommentListViewControllerPresentable {
    var commentsForCommentListViewController: Set<Comment> { return comments }
    func fetchCommentsForCommentListViewController(success success: (([Comment]) -> Void)?, failure: ((NSError) -> Void)?) {
        fetchComments(success: { success?($0) }, failure: failure)
    }
    func temporaryComment() -> Comment {
        let c = AnswerComment.temporaryObject() // manager.create("AnswerComment") as! AnswerComment
        c.answer = Answer.temporaryObject()
        c.answer!.id = id
        return c
    }
}

extension Article: CommentListViewControllerPresentable {
    var commentsForCommentListViewController: Set<Comment> { return comments }
    func fetchCommentsForCommentListViewController(success success: (([Comment]) -> Void)?, failure: ((NSError) -> Void)?) {
        fetchComments(success: { success?($0) }, failure: failure)
    }
    func temporaryComment() -> Comment {
        let c = ArticleComment.temporaryObject()
        c.article = Article.temporaryObject()
        c.article!.id = id
        return c
    }
}

class CommentListViewController: UITableViewController, UITextFieldDelegate {
    var dataObject: CommentListViewControllerPresentable
    var article: Article {
        return dataObject as! Article
    }
    var comments = [Comment]()
    var startEditing = false
    let cellReuseIdentifier = "CommentCell"
    let cellNibName = "CommentCell"
    var keyboardBar: KeyboardBar {
        return tableView.inputAccessoryView as! KeyboardBar
    }
    init(dataObject: CommentListViewControllerPresentable, editing: Bool) {
        /// @TODO: DELETE THIS.
        if let article = dataObject as? Article {
            self.dataObject = Article.cachedObjectWithID(article.id)
        } else {
            self.dataObject = dataObject
        }
        startEditing = editing
        super.init(nibName: nil, bundle: nil)
    }
    
    init(dataObject: CommentListViewControllerPresentable) {
        /// @TODO: DELETE THIS.
        if let article = dataObject as? Article {
            self.dataObject = Article.cachedObjectWithID(article.id)
        } else {
            self.dataObject = dataObject
        }
        super.init(nibName: nil, bundle: nil)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        super.loadView()
        title = "? 评论 · \(article.agreementCount ?? 0) 赞"
        tableView = TableViewWithKeyboardBar()
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.separatorStyle = .None
        tableView.contentInset.bottom = 8
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.keyboardDismissMode = .OnDrag
        tableView.backgroundColor = %+0xf2ede6
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(msr_navigationController!.interactivePopGestureRecognizer)
        keyboardBar.userAtView.removeButton.addTarget(self, action: "removeAtUser", forControlEvents: .TouchUpInside)
        keyboardBar.publishButton.addTarget(self, action: "publishComment", forControlEvents: .TouchUpInside)
        keyboardBar.textField.delegate = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sidebarDidBecomeVisible:", name: SidebarDidBecomeVisibleNotificationName, object: appDelegate.mainViewController.sidebar)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sidebarDidBecomeInvisible:", name: SidebarDidBecomeInvisibleNotificationName, object: appDelegate.mainViewController.sidebar)
        refreshControl!.beginRefreshing()
        refresh()
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.becomeFirstResponder()
        if startEditing {
            keyboardBar.textField.becomeFirstResponder()
        }
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.resignFirstResponder()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! CommentCell
        cell.update(comment: comment)
        cell.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        cell.replyButton.addTarget(self, action: "didPressReplyButton:", forControlEvents: .TouchUpInside)
        return cell
    }
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    func didPressUserButton(sender: UIButton) {
        keyboardBar.textField.resignFirstResponder()
        if let user = sender.msr_userInfo as? User {
            tableView.resignFirstResponder()
            msr_navigationController!.pushViewController(UserVC(user: user), animated: true)
        }
    }
    func didPressReplyButton(sender: UIButton) {
        keyboardBar.textField.resignFirstResponder()
        if let user = sender.msr_userInfo as? User {
            let temporaryUser = User.temporaryObject()
            temporaryUser.id = user.id
            temporaryUser.name = user.name
            keyboardBar.userAtView.msr_userInfo = temporaryUser
            keyboardBar.userAtView.userNameLabel.text = user.name
            keyboardBar.userAtView.hidden = false
            keyboardBar.textField.becomeFirstResponder()
        }
    }
    internal func publishComment() {
        if !(refreshControl?.refreshing ?? true) {
            keyboardBar.textField.resignFirstResponder()
            let comment = dataObject.temporaryComment()
            comment.body = keyboardBar.textField.text
            comment.atUser = keyboardBar.userAtView.msr_userInfo as? User
            SVProgressHUD.show()
            comment.post(
                success: {
                    [weak self] in
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccessWithStatus("已发布")
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue()) {
                        SVProgressHUD.dismiss()
                    }
                    self?.keyboardBar.textField.text = ""
                    self?.removeAtUser()
                    self?.refreshControl?.beginRefreshing()
                    self?.refresh()
                },
                failure: {
                    [weak self] error in
                    SVProgressHUD.dismiss()
                    let ac = UIAlertController(title: (error.userInfo[NSLocalizedDescriptionKey] as? String) ?? "",
                        message: nil,
                        preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                    self?.presentViewController(ac, animated: true, completion: nil)
                })
        }
    }
    func refresh() {
        dataObject.fetchCommentsForCommentListViewController(
            success: {
            [weak self] comments in
            self?.comments = comments
            self?.tableView.reloadData()
            self?.refreshControl!.endRefreshing()
        }, failure: {
            [weak self] error in
            self?.tableView.reloadData()
            self?.refreshControl!.endRefreshing()
        })
    }
    func removeAtUser() {
        keyboardBar.userAtView.msr_userInfo = nil
        animate() {
            [weak self] in
            self?.keyboardBar.userAtView.hidden = true
            self?.keyboardBar.userAtView.userNameLabel.text = ""
        }
    }
    func animate(animations: (() -> Void)) {
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.7,
            options: .BeginFromCurrentState,
            animations: animations,
            completion: nil)
    }
    func sidebarDidBecomeVisible(notification: NSNotification) {
        if msr_navigationController?.topViewController === self {
            keyboardBar.textField.resignFirstResponder()
            tableView.resignFirstResponder()
        }
    }
    func sidebarDidBecomeInvisible(notification: NSNotification) {
        if msr_navigationController?.topViewController === self {
            tableView.becomeFirstResponder()
        }
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
