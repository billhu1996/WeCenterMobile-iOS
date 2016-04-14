//
//  Article.swift
//  WeCenterMobile
//
//  Created by Darren Liu on 14/11/26.
//  Copyright (c) 2014年 Beijing Information Science and Technology University. All rights reserved.
//

import AFNetworking
import CoreData
import Foundation
import UIKit

class Article: DataObject {

    @NSManaged var agreementCount: NSNumber?
    @NSManaged var attachmentKey: String?
    @NSManaged var body: String?
    @NSManaged var date: NSDate?
    @NSManaged var title: String?
    @NSManaged var viewCount: NSNumber?
    @NSManaged var articleAgreementActions: Set<ArticleAgreementAction>
    @NSManaged var articlePublishmentActions: Set<ArticlePublishmentAction>
    @NSManaged var featuredObject: FeaturedArticle?
    @NSManaged var topics: Set<Topic>
    @NSManaged var user: User?
    @NSManaged var comments: Set<ArticleComment>
    @NSManaged var url: String?
    @NSManaged var imageURL: String?

    var evaluation: Evaluation? = nil
    var focusing: Bool? = nil
    
    var isPublishedByCurrentUser: Bool {
        return user?.isCurrentUser ?? false
    }
    
    var isInReadingList: Bool {
        return isPublishedByCurrentUser || (focusing ?? false)
    }
    
    class func fetch(ID ID: NSNumber, success: ((Article) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Article Detail",
            parameters: [
                "id": ID
            ],
            success: {
                data in
                let article = Article.cachedObjectWithID(ID)
                let info = data["article_info"] as! NSDictionary
                article.id = Int(msr_object: info["id"])!
                if let userID = Int(msr_object: info["uid"]) {
                    article.user = User.cachedObjectWithID(userID)
                    let userInfo = info["user_info"] as! NSDictionary
                    article.user!.name = (userInfo["user_name"] as! String)
                    article.user!.signature = userInfo["signature"] as? String
                    article.user!.avatarURL = userInfo["avatar_file"] as? String
                }
                article.title = (info["title"] as! String)
                article.body = (info["message"] as! String)
                let url = info["url"] as? String
                article.url = url ?? "" == "" ? nil : url
                article.agreementCount = Int(msr_object: info["votes"])
                if let voteInfo = info["vote_info"] as? [String: AnyObject] {
                    article.evaluation = Evaluation(rawValue: Int(msr_object: voteInfo["rating"])!)
                } else {
                    article.evaluation = Evaluation.None
                }
                article.topics = Set()
                article.focusing = Bool(msr_object: info["is_favorite"])
                if let topicsInfo = data["article_topics"] as? [NSDictionary] {
                    for topicInfo in topicsInfo {
                        let topicID = Int(msr_object: topicInfo["topic_id"])!
                        let topic = Topic.cachedObjectWithID(topicID)
                        topic.title = (topicInfo["topic_title"] as! String)
                        article.topics.insert(topic)
                    }
                }
                _ = try? DataManager.defaultManager.saveChanges()
                success?(article)
            },
            failure: failure)
    }
    
    func fetchComments(success success: (([ArticleComment]) -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.GET("Article Comment List",
            parameters: [
                "id": id
            ],
            success: {
                [weak self] data in
                if !MSRIsNilOrNull(data["rows"]) && Int(msr_object: data["total_rows"]) > 0 {
                    let commentsData = data["rows"] as! [NSDictionary]
                    var comments = [ArticleComment]()
                    self?.comments = Set()
                    for info in commentsData {
                        let comment = ArticleComment.cachedObjectWithID(Int(msr_object: info["id"])!)
                        comment.body = (info["message"] as! String)
                        comment.date = NSDate(timeIntervalSince1970: NSTimeInterval(msr_object: info["add_time"])!)
                        comment.agreementCount = Int(msr_object: info["votes"])
//                        comment.evaluation = Evaluation(rawValue: Int(msr_object: info["vote_value"])!)
                        if let userInfo = info["user_info"] as? NSDictionary {
                            comment.user = User.cachedObjectWithID(Int(msr_object: userInfo["uid"])!)
                            comment.user!.name = (userInfo["user_name"] as! String)
                            comment.user!.avatarURL = userInfo["avatar_file"] as? String
                        }
                        if let atUserInfo = info["at_user_info"] as? NSDictionary {
                            comment.atUser = User.cachedObjectWithID(Int(msr_object: atUserInfo["uid"])!)
                            comment.atUser!.name = (atUserInfo["user_name"] as! String)
                            comment.atUser!.avatarURL = atUserInfo["avatar_file"] as? String
                        }
                        comments.append(comment)
                        self?.comments.insert(comment)
                    }
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?(comments)
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func uploadImageWithJPEGData(jpegData: NSData, success: ((Int) -> Void)?, failure: ((NSError) -> Void)?) -> AFHTTPRequestOperation {
        return NetworkManager.defaultManager!.request("Upload Attachment",
            GETParameters: [
                "id": "article",
                "attach_access_key": attachmentKey!],
            POSTParameters: [:],
            constructingBodyWithBlock: {
                data in
                data?.appendPartWithFileData(jpegData, name: "qqfile", fileName: "image.jpg", mimeType: "image/jpeg")
                return
            },
            success: {
                data in
                success?(Int(msr_object: data["attach_id"])!)
                return
            },
            failure: failure)!
    }
    
    func evaluate(value value: Evaluation, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        let originalValue = evaluation
        if originalValue == nil {
            let userInfo = [
                NSLocalizedDescriptionKey: "Couldn't evaluate article now.",
                NSLocalizedFailureReasonErrorKey: "Current user evaluation data equals to nil. (article.evaluation == nil)"
            ]
            let error = NSError(
                domain: NetworkManager.defaultManager!.website,
                code: NetworkManager.defaultManager!.internalErrorCode.integerValue,
                userInfo: userInfo)
            failure?(error)
        }
        if value == originalValue {
            success?()
            return
        }
        NetworkManager.defaultManager!.POST("Evaluate Article",
            parameters: [
                "type": "article",
                "item_id": id,
                "rating": value.rawValue],
            success: {
                [weak self] _ in
                if let self_ = self {
                    self_.evaluation = value
                    if let count = self_.agreementCount?.integerValue {
                        self_.agreementCount = originalValue == .Up ? count - 1 : value == .Up ? count + 1 : count
                    }
                    _ = try? DataManager.defaultManager.saveChanges()
                    success?()
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func focus(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        NetworkManager.defaultManager!.POST("Focus Article/Answer",
            parameters: [
                "item_id": id,
                "item_type": "article"
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    self_.focusing = true
                    success?()
                } else {
                    failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                }
            },
            failure: failure)
    }
    
    func post(success success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        let topics = [Topic](self.topics)
        var topicsParameter = ""
        if topics.count == 1 {
            topicsParameter = topics[0].title!
        } else if topics.count > 1 {
            topicsParameter = topics.map({ $0.title! }).joinWithSeparator(",")
        }
        let title = self.title!
        let body = self.body!
        NetworkManager.defaultManager!.POST("Post Article",
            parameters: [
                "title": title,
                "message": body,
                "attach_access_key": attachmentKey!,
                "topics": topicsParameter
            ],
            success: {
                _ in
                success?()
                return
            },
            failure: failure)
    }
    
    func postWithURL(success success: ((Article) -> Void)?, failure: ((NSError) -> Void)?) {
        let url = self.url!
        NetworkManager.defaultManager!.POST("Post Article With URL",
            parameters: [
                "url": url
            ],
            success: {
                [weak self] data in
                if let self_ = self {
                    let id = Int(msr_object: data["article_id"])!
                    let article = Article.cachedObjectWithID(id)
                    article.url = self_.url
                    article.user = User.currentUser
                    success?(article)
                }
            },
            failure: failure)
    }
    
    var imageData: NSData?
    var image: UIImage? {
        get {
            if imageData != nil {
                return UIImage(data: imageData!)
            } else {
                return nil
            }
        }
        set {
            imageData = newValue == nil ? nil : UIImagePNGRepresentation(newValue!)
        }
    }
    
    private let imageView = UIImageView()
    func fetchImage(forced forced: Bool, success: (() -> Void)?, failure: ((NSError) -> Void)?) {
        if imageURL != nil {
            let request = NSMutableURLRequest(URL: NSURL(string: imageURL!)!)
            request.addValue("image/*", forHTTPHeaderField:"Accept")
            if forced {
                (UIImageView.sharedImageCache() as! NSCache).removeObjectForKey(request.URL!.absoluteString)
            }
            imageView.setImageWithURLRequest(request,
                placeholderImage: nil,
                success: {
                    [weak self] request, response, image in
                    if let self_ = self {
                        if self_.image == nil || response != nil {
                            self_.image = image
                            _ = try? DataManager.defaultManager.saveChanges()
                            success?()
                        } else {
                            failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                        }
                    } else {
                        failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
                    }
                },
                failure: {
                    _, _, error in
                    failure?(error)
                    return
            })
        } else {
            failure?(NSError(domain: NetworkManager.defaultManager!.website, code: NetworkManager.defaultManager!.internalErrorCode.integerValue, userInfo: nil)) // Needs specification
        }
    }
    
}
