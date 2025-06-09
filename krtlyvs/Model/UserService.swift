import FirebaseFirestore
import FirebaseStorage
import UIKit

struct UserService {
    // Callback tabanlı kullanıcı fetch
    static func fetchUser(withUid uid: String, completion: @escaping (User?) -> Void) {
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: Failed to fetch user: \(error.localizedDescription)")
                completion(nil)
                return
            }
            guard let data = snapshot?.data() else {
                completion(nil)
                return
            }
            let user = User(
                id: uid,
                email: data["email"] as? String ?? "",
                username: data["username"] as? String ?? "Bilinmeyen",
                profileImageUrl: data["profileImageUrl"] as? String ?? "",
                bio: data["bio"] as? String ?? ""
            )
            completion(user)
        }
    }

    // Async/await ile kullanıcı fetch (yeni eklendi)
    static func fetchUserAsync(withUid uid: String) async throws -> User {
        let document = try await Firestore.firestore().collection("users").document(uid).getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User data not found"])
        }
        
        return User(
            id: uid,
            email: data["email"] as? String ?? "",
            username: data["username"] as? String ?? "Bilinmeyen",
            profileImageUrl: data["profileImageUrl"] as? String ?? "",
            bio: data["bio"] as? String ?? ""
        )
    }
    
    // Async/await ile tüm kullanıcıları çek
    static func fetchAllUsers() async throws -> [User] {
        let snapshot = try await Firestore.firestore().collection("users").getDocuments()
        
        let users: [User] = snapshot.documents.compactMap { doc in
            let data = doc.data()
            return User(
                id: doc.documentID,
                email: data["email"] as? String ?? "",
                username: data["username"] as? String ?? "Bilinmeyen",
                profileImageUrl: data["profileImageUrl"] as? String ?? "",
                bio: data["bio"] as? String ?? ""
            )
        }
        return users
    }
    
    // Profil resmi URL'sini Firestore'da güncelle
    static func updateProfileImageURL(_ url: String, uid: String, completion: @escaping (Error?) -> Void) {
        let ref = Firestore.firestore().collection("users").document(uid)
        ref.updateData(["profileImageUrl": url]) { error in
            if let error = error {
                print("DEBUG: Failed to update profile image url: \(error.localizedDescription)")
            }
            completion(error)
        }
    }
    
    // Resmi Firebase Storage'a yükle ve Firestore URL'sini güncelle
    static func uploadProfileImage(_ image: UIImage, forUid uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Resim verisi oluşturulamadı"])))
            return
        }

        let storageRef = Storage.storage().reference().child("profile_images/\(uid).jpg")

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("🔴 Resim yükleme hatası: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("🔴 URL alma hatası: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let downloadURL = url else {
                    print("🔴 URL bulunamadı")
                    completion(.failure(NSError(domain: "DownloadURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL bulunamadı"])))
                    return
                }

                updateProfileImageURL(downloadURL.absoluteString, uid: uid) { error in
                    if let error = error {
                        print("🔴 Firestore güncelleme hatası: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }
                    completion(.success(downloadURL.absoluteString))
                }
            }
        }
    }
}
