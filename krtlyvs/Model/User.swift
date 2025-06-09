import Foundation
import FirebaseFirestore

struct UserStats: Codable {
    var followers: Int
    var following: Int
    var posts: Int
    
    init(dictionary: [String: Any]) {
        self.followers = dictionary["followers"] as? Int ?? 0
        self.following = dictionary["following"] as? Int ?? 0
        self.posts = dictionary["posts"] as? Int ?? 0
    }
    
    init(followers: Int = 0, following: Int = 0, posts: Int = 0) {
        self.followers = followers
        self.following = following
        self.posts = posts
    }
}

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let username: String
    var profileImageUrl: String
    var bio: String
    var isVerified: Bool
    var stats: UserStats?
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.isVerified = dictionary["isVerified"] as? Bool ?? false
        
        if let statsData = dictionary["stats"] as? [String: Any] {
            self.stats = UserStats(dictionary: statsData)
        }
    }
    
    init(id: String, email: String, username: String, profileImageUrl: String = "", bio: String = "", isVerified: Bool = false, stats: UserStats? = nil) {
        self.id = id
        self.email = email
        self.username = username
        self.profileImageUrl = profileImageUrl
        self.bio = bio
        self.isVerified = isVerified
        self.stats = stats
    }
    
    // Mock veri
    static let MOCK_USERS: [User] = [
        User(id: "1", email: "kartal@example.com", username: "kartal", profileImageUrl: "", bio: "iOS geliştirici", isVerified: true, stats: UserStats(followers: 100, following: 50, posts: 25)),
        User(id: "2", email: "ahmet@example.com", username: "ahmet", profileImageUrl: "", bio: "SwiftUI öğreniyor", isVerified: true, stats: UserStats(followers: 50, following: 100, posts: 10))
    ]
}
