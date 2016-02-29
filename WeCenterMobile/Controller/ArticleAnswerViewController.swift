//
//  ArticleAnswerViewController.swift
//  WeCenterMobile
//
//  Created by Bill Hu on 16/2/23.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import DTCoreText
import MJRefresh
import SVProgressHUD
import UIKit

class ArticleAnswerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DTLazyImageViewDelegate, QuestionBodyCellLinkButtonDelegate, PublishmentViewControllerDelegate {
    
    var dataObject: ArticleViewControllerPresentable
    var comments = [Comment]()
    let cellReuseIdentifier = "CommentCell"
    let cellNibName = "CommentCell"
    
    lazy var questionHeaderCell: QuestionHeaderCell = {
        [weak self] in
        let c = NSBundle.mainBundle().loadNibNamed("QuestionHeaderCell", owner: nil, options: nil).first as! QuestionHeaderCell
        c.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
        return c
        }()
    lazy var questionTitleCell: QuestionTitleCell = {
        [weak self] in
        return NSBundle.mainBundle().loadNibNamed("QuestionTitleCell", owner: nil, options: nil).first as! QuestionTitleCell
        }()
    lazy var questionBodyCell: QuestionBodyCell = {
        [weak self] in
        let c = NSBundle.mainBundle().loadNibNamed("QuestionBodyCell", owner: nil, options: nil).first as! QuestionBodyCell
        if let self_ = self {
            c.lazyImageViewDelegate = self_
            c.linkButtonDelegate = self_
            NSNotificationCenter.defaultCenter().addObserver(self_, selector: "attributedTextContentViewDidFinishLayout:", name: DTAttributedTextContentViewDidFinishLayoutNotification, object: c.attributedTextContextView)
        }
        return c
        }()
    
    lazy var commentHeaderView: CommentHeaderView = {
        let c = NSBundle.mainBundle().loadNibNamed("CommentHeaderView", owner: nil, options: nil).first as! CommentHeaderView
        return c
    }()
    
    lazy var commentFooterView: CommentFooterView = {
        let c = NSBundle.mainBundle().loadNibNamed("CommentFooterView", owner: nil, options: nil).first as! CommentFooterView
        c.commentButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
        return c
    }()
    
    lazy var tableView: UITableView = {
        [weak self] in
        let v = UITableView()
        v.delegate = self
        v.dataSource = self
        return v
        }()
    
    lazy var footer: ArticleFooterView = {
        [weak self] in
        let v = NSBundle.mainBundle().loadNibNamed("ArticleFooterView", owner: nil, options: nil).first as! ArticleFooterView
        v.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        return v
        }()
    
    init(dataObject: ArticleViewControllerPresentable) {
        self.dataObject = dataObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        let theme = SettingsManager.defaultManager.currentTheme
        view.backgroundColor = theme.backgroundColorA
        tableView.backgroundColor = theme.backgroundColorA
        view.addSubview(tableView)
        view.addSubview(footer)
        view.bringSubviewToFront(footer)
        tableView.frame = CGRect(x: 0, y:  0, width: view.bounds.width, height: view.bounds.height - 44)
        footer.frame = CGRect(x: 0, y: view.bounds.height - 44, width: view.bounds.width, height: 44)
        tableView.indicatorStyle = theme.scrollViewIndicatorStyle
        tableView.delaysContentTouches = false
        tableView.msr_wrapperView?.delaysContentTouches = false
        tableView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: cellNibName, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(msr_navigationController!.interactivePopGestureRecognizer)
        tableView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        tableView.wc_addRefreshingHeaderWithTarget(self, action: "refresh")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Share-Button"), style: .Plain, target: self, action: "didPressShareButton")
        footer.commentItem.action = "didPressAnswerButton"
        footer.commentItem.target = self
        footer.addButton.action = "didPressAddButton"
        footer.addButton.target = self
        footer.agreeItem.action = "didPressAgreeButton"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.mj_header.beginRefreshing()
        tableView.becomeFirstResponder()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [1, 1, 1, min(comments.count, 5), 1][section]
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 3 ? 30 : 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return  section == 3 ? commentHeaderView : nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            questionHeaderCell.update(user: dataObject.user, updateImage: true)
            return questionHeaderCell
        case 1:
            questionTitleCell.update(dataObject: dataObject)
            return questionTitleCell
        case 2:
            questionBodyCell.update(dataObject: dataObject)
            return questionBodyCell
        case 3:
            let commentCell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! CommentCell
            commentCell.userButton.addTarget(self, action: "didPressUserButton:", forControlEvents: .TouchUpInside)
            commentCell.commentButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: .TouchUpInside)
            commentCell.update(comment: comments[indexPath.row])
            return commentCell
        default:
            commentFooterView.commentButton.addTarget(self, action: "didPressAnswerButton:", forControlEvents: UIControlEvents.TouchUpInside)
            return commentFooterView
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        struct _Static {
            static var id: dispatch_once_t = 0
            static var commentCell: CommentCell!
        }
        dispatch_once(&_Static.id) {
            [weak self] in
            if let self_ = self {
                _Static.commentCell = NSBundle.mainBundle().loadNibNamed(self_.cellReuseIdentifier, owner: nil, options: nil).first as! CommentCell
            }
        }
        switch indexPath.section {
        case 0:
            questionHeaderCell.update(user: dataObject.user, updateImage: false)
            return questionHeaderCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 1:
            questionTitleCell.update(dataObject: dataObject)
            return questionTitleCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        case 2:
            questionBodyCell.update(dataObject: dataObject)
            let height = questionBodyCell.requiredRowHeightInTableView(tableView)
            let insets = questionBodyCell.attributedTextContextView.edgeInsets
            return height > insets.top + insets.bottom ? height : 0
        case 3:
            _Static.commentCell.update(comment: comments[indexPath.row])
            return _Static.commentCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        default:
            return commentFooterView.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        }
    }
    
    func lazyImageView(lazyImageView: DTLazyImageView!, didChangeImageSize size: CGSize) {
        let predicate = NSPredicate(format: "contentURL == %@", lazyImageView.url)
        let attachments = questionBodyCell.attributedTextContextView.layoutFrame.textAttachmentsWithPredicate(predicate) as? [DTImageTextAttachment] ?? []
        for attachment in attachments {
            attachment.originalSize = size
            let v = questionBodyCell.attributedTextContextView
            let maxWidth = v.bounds.width - v.edgeInsets.left - v.edgeInsets.right
            if size.width > maxWidth {
                let scale = maxWidth / size.width
                attachment.displaySize = CGSize(width: size.width * scale, height: size.height * scale)
            }
        }
        questionBodyCell.attributedTextContextView.layouter = nil
        questionBodyCell.attributedTextContextView.relayoutText()
    }
    
    func didLongPressLinkButton(linkButton: DTLinkButton) {
        presentLinkAlertControllerWithURL(linkButton.URL)
    }
    
    func didPressLinkButton(linkButton: DTLinkButton) {
        presentLinkAlertControllerWithURL(linkButton.URL)
    }
    
    func presentLinkAlertControllerWithURL(URL: NSURL) {
        let ac = UIAlertController(title: "链接", message: URL.absoluteString, preferredStyle: .ActionSheet)
        ac.addAction(UIAlertAction(title: "跳转到 Safari", style: .Default) {
            action in
            UIApplication.sharedApplication().openURL(URL)
            })
        ac.addAction(UIAlertAction(title: "复制到剪贴板", style: .Default) {
            action in
            UIPasteboard.generalPasteboard().string = URL.absoluteString
            SVProgressHUD.showSuccessWithStatus("已复制")
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC / 2)), dispatch_get_main_queue()) {
                SVProgressHUD.dismiss()
            }
            })
        ac.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    func didPressUserButton(sender: UIButton) {
        if let user = sender.msr_userInfo as? User {
            msr_navigationController!.pushViewController(UserVC(user: user), animated: true)
        }
    }
    
    func didPressAnswerButton(sender: UIButton) {
        if let dataObject = dataObject as? CommentListViewControllerPresentable {
            msr_navigationController!.pushViewController(CommentListViewController(dataObject: dataObject), animated: true)
        }
    }
    
    func didPressAnswerButton() {
        if let dataObject = dataObject as? CommentListViewControllerPresentable {
            msr_navigationController!.pushViewController(CommentListViewController(dataObject: dataObject, editing: true), animated: true)
        }
    }
    
    func didPressAddButton() {
        let alert = UIAlertController(title: "确认添加到在读列表？", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func didPressAgreeButton() {
        if let rawValue = dataObject.evaluationRawValue?.integerValue {
            let e = Evaluation(rawValue: rawValue)!
            evaluate(value: e == .Up ? .None : .Up)
        }
    }
    
    
    func evaluate(value value: Evaluation) {
        let count = dataObject.agreementCount?.integerValue
        dataObject.agreementCount = nil
        footer.update(dataObject: dataObject)
        dataObject.agreementCount = count
        dataObject.evaluate(
            value: value,
            success: {
                [weak self] in
                self?.footer.update(dataObject: self!.dataObject)
                return
            },
            failure: {
                [weak self] error in
                self?.footer.update(dataObject: self!.dataObject)
                let message = error.userInfo[NSLocalizedDescriptionKey] as? String ?? "未知错误"
                let ac = UIAlertController(title: "错误", message: message, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "好", style: .Default, handler: nil))
                self?.showDetailViewController(ac, sender: self)
                return
            })
    }
    
//    func didPressAdditionButton() {
//        let apc = NSBundle.mainBundle().loadNibNamed("PublishmentViewControllerB", owner: nil, options: nil).first as! PublishmentViewController
//        let answer = Answer.temporaryObject()
//        answer.question = Question.temporaryObject()
//        answer.question!.id = question.id
//        apc.delegate = self
//        apc.dataObject = answer
//        apc.headerLabel.text = "发布回答"
//        showDetailViewController(apc, sender: self)
//    }
    
    func publishmentViewControllerDidSuccessfullyPublishDataObject(publishmentViewController: PublishmentViewController) {
        tableView.mj_header.beginRefreshing()
    }
    
//    func toggleFocus() {
//        let focusing = question.focusing
//        question.focusing = nil
//        reloadQuestionFooterCell()
//        question.toggleFocus(
//            success: {
//                [weak self] in
//                self?.reloadQuestionFooterCell()
//                return
//            },
//            failure: {
//                [weak self] error in
//                self?.question.focusing = focusing
//                self?.reloadQuestionFooterCell()
//            })
//    }
    
    func refresh() {
        dataObject.fetchDataObjectForArticleViewController(
            success: {
                [weak self] dataObject in
                self?.dataObject = dataObject
                self?.reloadData()
                self?.tableView.mj_header.endRefreshing()
            }, failure: {
                [weak self] error in
                self?.tableView.mj_header.endRefreshing()
                return
            })
    }
    
    func reloadData() {
        let theme = SettingsManager.defaultManager.currentTheme
        let options = [
            DTDefaultFontName: UIFont.systemFontOfSize(0).fontName,
            DTDefaultFontSize: 16,
            DTDefaultTextColor: theme.bodyTextColor,
            DTDefaultLineHeightMultiplier: 1.5,
            DTDefaultLinkColor: UIColor.msr_materialLightBlue(),
            DTDefaultLinkDecoration: true]
        questionHeaderCell.update(user: dataObject.user, updateImage: true)
        footer.update(dataObject: dataObject)
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let html = dataObject.date == nil || dataObject.body == nil ? dataObject.body ?? "加载中……" : dataObject.body! + "<br><p align=\"right\">\(dateFormatter.stringFromDate(dataObject.date!))</p>"
        questionBodyCell.attributedString = NSAttributedString(
            HTMLData: html.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true),
            options: options,
            documentAttributes: nil)
        
        if let dataObject = dataObject as? CommentListViewControllerPresentable {
            dataObject.fetchCommentsForCommentListViewController(
                success: {
                    [weak self] comments in
                    self?.comments = comments
                    self?.tableView.reloadData()
                    self?.tableView.mj_header.endRefreshing()
                }, failure: {
                    [weak self] error in
                    self?.tableView.reloadData()
                    self?.tableView.mj_header.endRefreshing()
                })
        }
//        bodyView.relayoutText()
    }
    
    func reloadQuestionFooterCell() {
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 4)], withRowAnimation: .None)
    }
    
    func didPressShareButton() {
        let title = dataObject.title!
        let image = dataObject.user?.avatar ?? defaultUserAvatar
        let body = dataObject.body!.wc_plainString
        let url: String = (dataObject is Answer) ? "\(NetworkManager.defaultManager!.website)?/question/\((dataObject as! Answer).question!.id)" : "\(NetworkManager.defaultManager!.website)?/article/\(dataObject.id)"
        var items = [title, body, NSURL(string: url)!]
        if image != nil {
            items.append(image!)
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: [SinaWeiboActivity(), WeChatSessionActivity(), WeChatTimelineActivity()])
        showDetailViewController(vc, sender: self)
    }
    
    func didPressTagsButton(sender: UIButton) {
        if let topics = sender.msr_userInfo as? [Topic] {
            msr_navigationController!.pushViewController(TopicListViewController(topics: topics), animated: true)
        }
    }
    
    func attributedTextContentViewDidFinishLayout(notification: NSNotification) {
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
