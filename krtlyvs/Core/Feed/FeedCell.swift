import SwiftUI
import Foundation
import Firebase
import FirebaseFirestore

struct FeedCell: View {
    @Binding var post: Post
    let currentUserUid: String
    @State private var showComments = false
    @State private var isLiking = false
    @State private var errorMessage: String?
    
    private var isLiked: Bool {
        post.likes.contains(currentUserUid)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Kullanıcı bilgileri
            HStack {
                if let user = post.user {
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
                    
                    Text(user.username)
                        .font(.headline)
                }
                
                Spacer()
                
                Button {
                    // Gelecekte paylaşım seçenekleri eklenebilir
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 8)
            
            // Post görseli
            AsyncImage(url: URL(string: post.imageUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(maxHeight: 400)
            .clipped()
            
            // Etkileşim butonları
            HStack(spacing: 16) {
                Button {
                    Task {
                        await handleLike()
                    }
                } label: {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .primary)
                }
                .disabled(isLiking)
                
                Button {
                    showComments = true
                } label: {
                    Image(systemName: "bubble.right")
                }
                
                Button {
                    // Gelecekte paylaşım özelliği eklenebilir
                } label: {
                    Image(systemName: "paperplane")
                }
                
                Spacer()
                
                Button {
                    // Gelecekte kaydetme özelliği eklenebilir
                } label: {
                    Image(systemName: "bookmark")
                }
            }
            .font(.title3)
            .padding(.horizontal, 8)
            
            // Beğeni sayısı
            if !post.likes.isEmpty {
                Text("\(post.likes.count) beğeni")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
            }
            
            // Açıklama
            if !post.caption.isEmpty {
                HStack {
                    if let user = post.user {
                        Text(user.username)
                            .fontWeight(.semibold)
                    }
                    Text(post.caption)
                }
                .font(.subheadline)
                .padding(.horizontal, 8)
            }
            
            // Yorum sayısı
            if !post.comments.isEmpty {
                Button {
                    showComments = true
                } label: {
                    Text("\(post.comments.count) yorumun tümünü gör")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 8)
            }
            
            // Zaman
            Text(post.timestamp.timeAgoDisplay())
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
        }
        .sheet(isPresented: $showComments) {
            CommentsView(post: post)
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
    
    private func handleLike() async {
        guard !isLiking else { return }
        isLiking = true
        defer { isLiking = false }
        
        do {
            try await PostService.shared.updateLikes(for: post) { updatedPost in
                post = updatedPost
            }
        } catch {
            errorMessage = "Beğeni işlemi sırasında bir hata oluştu: \(error.localizedDescription)"
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfMonth], from: self, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day)g önce"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)s önce"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)d önce"
        } else {
            return "Şimdi"
        }
    }
}
