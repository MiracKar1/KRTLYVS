import Foundation
import FirebaseFirestore
import FirebaseAuth
import krtlyvs

class PostService {
    static let shared = PostService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchAllPosts() async throws -> [Post] {
        let snapshot = try await db.collection("posts")
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        var posts: [Post] = []
        
        for document in snapshot.documents {
            let data = document.data()
            var post = Post(dictionary: data)
            
            // Kullanıcı bilgilerini getir
            if let userDoc = try? await db.collection("users")
                .document(post.ownerUid)
                .getDocument(),
               let userData = userDoc.data() {
                post.user = User(dictionary: userData)
            }
            
            // Yorumları getir
            let commentsSnapshot = try await db.collection("posts")
                .document(post.id)
                .collection("comments")
                .order(by: "timestamp", descending: false)
                .getDocuments()
            
            post.comments = commentsSnapshot.documents.compactMap { document in
                Comment(dictionary: document.data())
            }
            
            posts.append(post)
        }
        
        return posts
    }
    
    func updateLikes(for post: Post, completion: @escaping (Post) -> Void) async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        var updatedPost = post
        
        if post.likes.contains(currentUser.uid) {
            updatedPost.likes.removeAll { $0 == currentUser.uid }
        } else {
            updatedPost.likes.append(currentUser.uid)
            
            // Bildirim gönder
            try await NotificationService.shared.uploadNotification(
                toUid: post.ownerUid,
                fromUserUid: currentUser.uid,
                type: .like,
                postId: post.id
            )
        }
        
        try await db.collection("posts")
            .document(post.id)
            .updateData(["likes": updatedPost.likes])
        
        completion(updatedPost)
    }
    
    func addPost(_ post: Post) async throws {
        let postRef = db.collection("posts").document(post.id)
        
        try await postRef.setData([
            "id": post.id,
            "ownerUid": post.ownerUid,
            "caption": post.caption,
            "imageUrl": post.imageUrl,
            "timestamp": Timestamp(date: post.timestamp),
            "likes": post.likes
        ])
    }
    
    func deletePost(withId id: String) async throws {
        try await db.collection("posts")
            .document(id)
            .delete()
    }
    
    func addComment(_ comment: Comment, toPost post: Post) async throws {
        let commentRef = db.collection("posts")
            .document(post.id)
            .collection("comments")
            .document(comment.id)
        
        try await commentRef.setData([
            "id": comment.id,
            "userUid": comment.userUid,
            "username": comment.username,
            "text": comment.text,
            "timestamp": Timestamp(date: comment.timestamp)
        ])
    }
    
    func fetchComments(forPost post: Post) async throws -> [Comment] {
        let snapshot = try await db.collection("posts")
            .document(post.id)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            Comment(dictionary: document.data())
        }
    }
}
