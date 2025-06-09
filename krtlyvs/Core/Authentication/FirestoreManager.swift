import Firebase
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchPosts() async throws -> [Post] {
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
    
    func fetchUser(withUid uid: String) async throws -> User {
        let snapshot = try await db.collection("users")
            .document(uid)
            .getDocument()
        
        guard let data = snapshot.data() else {
            throw NSError(domain: "FirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı bulunamadı"])
        }
        
        return User(dictionary: data)
    }
    
    func updateUser(_ user: User) async throws {
        try await db.collection("users")
            .document(user.id)
            .setData([
                "id": user.id,
                "email": user.email,
                "username": user.username,
                "profileImageUrl": user.profileImageUrl,
                "bio": user.bio,
                "isVerified": user.isVerified
            ])
    }
}
