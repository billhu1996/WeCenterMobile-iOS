//
//  UserVC.swift
//  WeCenterMobile
//
//  Created by GaoMing on 16/2/23.
//  Copyright © 2016年 Beijing Information Science and Technology University. All rights reserved.
//

import Foundation
import UIKit

class UserVC: UITableViewController {
    var user: User
    
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
    
    override func viewDidLoad() {
        super.loadView()
        refresh()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 5
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return self.userCell
        } else {
            let cell = UITableViewCell()
            return cell
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        } else {
            return 50
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
    }
    func reloadData() {
        self.navigationController?.title = self.user.name
        self.userCell.update(user: self.user)
        self.tableView.reloadData()
    }
}

