import Foundation
import FirebaseFirestore
import FirebaseAuth

class NotificationService {
    static let shared = NotificationService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func uploadNotification(
        toUid: String,
        fromUserUid: String,
        type: NotificationType,
        postId: String? = nil
    ) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "NotificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu bulunamadı"])
        }
        
        let notification = UserNotification(
            id: UUID().uuidString,
            userUid: toUid,
            fromUserUid: fromUserUid,
            type: type,
            postId: postId,
            timestamp: Date(),
            isRead: false
        )
        
        let notificationRef = db.collection("notifications")
            .document(notification.id)
        
        try await notificationRef.setData([
            "id": notification.id,
            "userUid": notification.userUid,
            "fromUserUid": notification.fromUserUid,
            "type": notification.type.rawValue,
            "postId": notification.postId as Any,
            "timestamp": Timestamp(date: notification.timestamp),
            "isRead": notification.isRead
        ])
    }
    
    func fetchNotifications() async throws -> [UserNotification] {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "NotificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Kullanıcı oturumu bulunamadı"])
        }
        
        let snapshot = try await db.collection("notifications")
            .whereField("userUid", isEqualTo: currentUser.uid)
            .order(by: "timestamp", descending: true)
            .getDocuments()
        
        var notifications: [UserNotification] = []
        
        for document in snapshot.documents {
            let data = document.data()
            let notification = UserNotification(dictionary: data)
            
            // Kullanıcı bilgilerini getir
            if let userDoc = try? await db.collection("users")
                .document(notification.fromUserUid)
                .getDocument(),
               let userData = userDoc.data() {
                let user = User(dictionary: userData)
                var notificationWithUser = notification
                notificationWithUser.user = user
                notifications.append(notificationWithUser)
            } else {
                notifications.append(notification)
            }
        }
        
        return notifications
    }
    
    func deleteNotification(_ notification: UserNotification) async throws {
        try await db.collection("notifications")
            .document(notification.id)
            .delete()
    }
    
    func markNotificationAsRead(_ notification: UserNotification) async throws {
        try await db.collection("notifications")
            .document(notification.id)
            .updateData(["isRead": true])
    }
    
    func markAllNotificationsAsRead() async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let snapshot = try await db.collection("notifications")
            .whereField("userUid", isEqualTo: currentUser.uid)
            .whereField("isRead", isEqualTo: false)
            .getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.updateData(["isRead": true])
        }
    }
}
