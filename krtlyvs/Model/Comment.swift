import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    let id: String
    let userUid: String
    let username: String
    let text: String
    let timestamp: Date
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.userUid = dictionary["userUid"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.text = dictionary["text"] as? String ?? ""
        
        if let timestamp = dictionary["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else if let date = dictionary["timestamp"] as? Date {
            self.timestamp = date
        } else {
            self.timestamp = Date()
        }
    }
    
    init(id: String, userUid: String, username: String, text: String, timestamp: Date = Date()) {
        self.id = id
        self.userUid = userUid
        self.username = username
        self.text = text
        self.timestamp = timestamp
    }
}
