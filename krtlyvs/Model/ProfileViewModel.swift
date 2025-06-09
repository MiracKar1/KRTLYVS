import Foundation
import FirebaseFirestore

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var profileImageUrl: String = ""
    @Published var username: String = ""
    @Published var postCount: Int = 0
    @Published var followersCount: Int = 0
    @Published var followingCount: Int = 0

    private let userId: String
    private let db = Firestore.firestore()

    init(userId: String) {
        self.userId = userId
        Task {
            await fetchUserProfile()
            await fetchPosts()
        }
    }

    func fetchUserProfile() async {
        do {
            let docRef = db.collection("users").document(userId)
            let snapshot = try await docRef.getDocument()

            guard let data = snapshot.data() else {
                print("Kullanıcı verisi yok")
                return
            }

            let user = User(dictionary: data)
            self.username = user.username
            self.profileImageUrl = user.profileImageUrl ?? ""
            // followersCount ve followingCount Firestore'da farklı yerde ise onları da çek
        } catch {
            print("Profil verisi alınırken hata: \(error.localizedDescription)")
        }
    }

    func fetchPosts() async {
        do {
            let querySnapshot = try await db.collection("posts")
                .whereField("ownerUid", isEqualTo: userId)
                .getDocuments()

            var fetchedPosts: [Post] = []

            for document in querySnapshot.documents {
                let data = document.data()
                let post = Post(dictionary: data)
                fetchedPosts.append(post)
            }

            // timestamp optional, nil ise en eski sayalım
            self.posts = fetchedPosts.sorted {
                ($0.timestamp ?? Date.distantPast) > ($1.timestamp ?? Date.distantPast)
            }
            self.postCount = posts.count
        } catch {
            print("Gönderiler alınırken hata: \(error.localizedDescription)")
        }
    }
}
