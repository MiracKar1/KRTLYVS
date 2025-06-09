import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    let id: String
    let ownerUid: String
    let caption: String
    let imageUrl: String
    let timestamp: Date
    var likes: [String]
    var comments: [Comment]
    
    var user: User?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.likes = dictionary["likes"] as? [String] ?? []
        self.comments = []
        
        if let timestamp = dictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }
    }
    
    init(id: String, ownerUid: String, caption: String, imageUrl: String, timestamp: Date = Date(), likes: [String] = [], comments: [Comment] = []) {
        self.id = id
        self.ownerUid = ownerUid
        self.caption = caption
        self.imageUrl = imageUrl
        self.timestamp = timestamp
        self.likes = likes
        self.comments = comments
    }
}
