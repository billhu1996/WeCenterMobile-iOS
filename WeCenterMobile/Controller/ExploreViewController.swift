//
//  ExploreViewController.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/7/30.
//  Copyright (c) 2014年 ifLab. All rights reserved.
//

import UIKit

class ExploreViewController: MSRSegmentedViewController, MSRSegmentedViewControllerDelegate {
    
    override class var positionOfSegmentedControl: MSRSegmentedControlPosition {
        return .Top
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "发现"
        label.textColor = .whiteColor()
        label.font = UIFont.boldSystemFontOfSize(17)
        label.sizeToFit()
        return label
    }()
    
    override func loadView() {
        super.loadView()
        navigationItem.titleView = titleLabel
        let theme = SettingsManager.defaultManager.currentTheme
//        navigationController?.navigationBar.tintColor = .whiteColor()//theme.titleTextColor
        segmentedControl.indicator = MSRSegmentedControlBlockIndicator()
        segmentedControl.tintColor = UIColor.whiteColor().colorWithAlphaComponent(0.87)
        segmentedControl.indicator.tintColor = UIColor.clearColor()
        segmentedControl.backgroundView = UIView()
        segmentedControl.backgroundView!.backgroundColor = %+0x3a374a
        segmentedControl.msr_heightConstraint!.constant = 36
        view.backgroundColor = theme.backgroundColorA
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Navigation-Root"), style: .Plain, target: self, action: "showSidebar")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Sidebar-Search"), style: .Plain, target: self, action: "didPressSearchButton:")
        msr_navigationBar!.msr_shadowImageView?.hidden = true
        scrollView.msr_setTouchesShouldCancel(true, inContentViewWhichIsKindOfClass: UIButton.self)
        scrollView.delaysContentTouches = false
        scrollView.panGestureRecognizer.requireGestureRecognizerToFail(appDelegate.mainViewController.sidebar.screenEdgePanGestureRecognizer)
        delegate = self
    }
    
    var firstAppear = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            firstAppear = false
            let titles: [(FeaturedObjectListType, String)] = [
                (.Recommended, "推荐"),
                (.Famous, "名人"),
                (.Hot, "媒体"),]
//                (.New, "最新"),
//                (.Unsolved, "等待回答"),]
            // [FeaturedObjectListType: String] is not SequenceType
            let vcs: [UIViewController] = titles.map {
                (type, title) in
                if type == .Recommended {
                    let vc = FeaturedObjectListViewController(type: type)
                    vc.title = title
                    return vc
                } else {
                    let listType: UserListType = type == .Famous ? .Famous : .Media
                    let vc = UserListViewController(user: User.currentUser!, listType: listType)
                    vc.title = title
                    return vc
                }
            }
            setViewControllers(vcs, animated: false)
            for i in 0..<numberOfViewControllers {
                let s = segmentedControl.segmentAtIndex(i) as! MSRDefaultSegment
                s.titleLabel.font = UIFont.systemFontOfSize(14)
            }
        }
    }
    
    func msr_segmentedViewController(segmentedViewController: MSRSegmentedViewController, didSelectViewController viewController: UIViewController?) {
        (viewController as? FeaturedObjectListViewController)?.segmentedViewControllerDidSelectSelf(segmentedViewController)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return SettingsManager.defaultManager.currentTheme.statusBarStyle
    }
    
    func showSidebar() {
        appDelegate.mainViewController.sidebar.expand()
    }
    
    func didPressPublishButton() {
        let ac = UIAlertController(title: "发布什么？", message: "选择发布的内容种类。", preferredStyle: .ActionSheet)
        let presentPublishmentViewController: (String, PublishmentViewControllerPresentable) -> Void = {
            [weak self] title, object in
            let vc = NSBundle.mainBundle().loadNibNamed("PublishmentViewControllerA", owner: nil, options: nil).first as! PublishmentViewController
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
    
    func didPressSearchButton(sender: UIButton) {
        msr_navigationController!.pushViewController(SearchViewController(nibName: nil, bundle: nil), animated: false)
    }
    
}

