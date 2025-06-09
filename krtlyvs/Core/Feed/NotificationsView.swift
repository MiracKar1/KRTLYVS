//
//  NotificationsView.swift
//  krtlyvs
//
//  Created by Mirac Kar on 1.06.2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct NotificationsView: View {
    @State private var notifications: [UserNotification] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedNotification: UserNotification?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if notifications.isEmpty && !isLoading {
                    ContentUnavailableView(
                        "Bildirim Yok",
                        systemImage: "bell.slash",
                        description: Text("Henüz hiç bildiriminiz yok")
                    )
                } else {
                    List(notifications) { notification in
                        NotificationCell(notification: notification)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedNotification = notification
                                Task {
                                    await markNotificationAsRead(notification)
                                }
                            }
                    }
                    .refreshable {
                        await fetchNotifications()
                    }
                }
                
                if isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Bildirimler")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !notifications.isEmpty {
                        Button("Tümünü Okundu İşaretle") {
                            Task {
                                await markAllAsRead()
                            }
                        }
                    }
                }
            }
            .alert("Hata", isPresented: .constant(errorMessage != nil)) {
                Button("Tamam") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .task {
            await fetchNotifications()
        }
    }
    
    private func fetchNotifications() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            notifications = try await NotificationService.shared.fetchNotifications()
        } catch {
            errorMessage = "Bildirimler yüklenirken bir hata oluştu: \(error.localizedDescription)"
        }
    }
    
    private func markNotificationAsRead(_ notification: UserNotification) async {
        do {
            try await NotificationService.shared.markNotificationAsRead(notification)
            if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                notifications[index].isRead = true
            }
        } catch {
            errorMessage = "Bildirim okundu olarak işaretlenirken bir hata oluştu: \(error.localizedDescription)"
        }
    }
    
    private func markAllAsRead() async {
        do {
            try await NotificationService.shared.markAllNotificationsAsRead()
            notifications = notifications.map { notification in
                var updatedNotification = notification
                updatedNotification.isRead = true
                return updatedNotification
            }
        } catch {
            errorMessage = "Bildirimler okundu olarak işaretlenirken bir hata oluştu: \(error.localizedDescription)"
        }
    }
}

struct NotificationCell: View {
    let notification: UserNotification
    
    var body: some View {
        HStack(spacing: 12) {
            if let user = notification.user {
                AsyncImage(url: URL(string: user.profileImageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notificationText)
                    .font(.subheadline)
                
                Text(notification.timestamp.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if !notification.isRead {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
        .opacity(notification.isRead ? 0.6 : 1.0)
    }
    
    private var notificationText: String {
        if let user = notification.user {
            switch notification.type {
            case .like:
                return "\(user.username) gönderini beğendi"
            case .comment:
                return "\(user.username) gönderine yorum yaptı"
            case .follow:
                return "\(user.username) seni takip etmeye başladı"
            }
        }
        return ""
    }
}
