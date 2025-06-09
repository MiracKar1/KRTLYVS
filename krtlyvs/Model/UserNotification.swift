//
//  UserNotification.swift
//  krtlyvs
//
//  Created by Mirac Kar on 1.06.2025.
//

import Foundation
import FirebaseFirestore

enum NotificationType: String, Codable {
    case like = "like"
    case comment = "comment"
    case follow = "follow"
}

struct UserNotification: Identifiable, Codable {
    let id: String
    let userUid: String
    let fromUserUid: String
    let type: NotificationType
    let postId: String?
    let timestamp: Date
    var isRead: Bool
    
    var user: User?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.userUid = dictionary["userUid"] as? String ?? ""
        self.fromUserUid = dictionary["fromUserUid"] as? String ?? ""
        self.type = NotificationType(rawValue: dictionary["type"] as? String ?? "") ?? .like
        self.postId = dictionary["postId"] as? String
        self.isRead = dictionary["isRead"] as? Bool ?? false
        
        if let timestamp = dictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }
    }
    
    init(id: String, userUid: String, fromUserUid: String, type: NotificationType, postId: String? = nil, timestamp: Date = Date(), isRead: Bool = false) {
        self.id = id
        self.userUid = userUid
        self.fromUserUid = fromUserUid
        self.type = type
        self.postId = postId
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
