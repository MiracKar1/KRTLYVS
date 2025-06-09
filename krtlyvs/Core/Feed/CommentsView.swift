import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct CommentsView: View {
    let post: Post
    @State private var commentText = ""
    @State private var comments: [Comment] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(comments) { comment in
                                CommentCell(comment: comment)
                            }
                        }
                        .padding()
                    }
                    
                    Divider()
                    
                    HStack {
                        TextField("Yorum yaz...", text: $commentText)
                            .textFieldStyle(.roundedBorder)
                        
                        Button {
                            Task {
                                await addComment()
                            }
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.blue)
                        }
                        .disabled(commentText.isEmpty || isLoading)
                    }
                    .padding()
                }
                
                if isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Yorumlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Kapat") {
                        dismiss()
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
            await fetchComments()
        }
    }
    
    private func fetchComments() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            comments = try await PostService.shared.fetchComments(forPost: post)
        } catch {
            errorMessage = "Yorumlar yüklenirken bir hata oluştu: \(error.localizedDescription)"
        }
    }
    
    private func addComment() async {
        guard !commentText.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let currentUser = Auth.auth().currentUser
            let userUid = currentUser?.uid ?? ""
            let username = currentUser?.displayName ?? "Kullanıcı"
            
            let comment = Comment(
                id: UUID().uuidString,
                userUid: userUid,
                username: username,
                text: commentText,
                timestamp: Date()
            )
            
            try await PostService.shared.addComment(comment, toPost: post)
            comments.append(comment)
            commentText = ""
            
            // Bildirim gönder
            if post.ownerUid != userUid {
                try await NotificationService.shared.uploadNotification(
                    toUid: post.ownerUid,
                    fromUserUid: userUid,
                    type: .comment,
                    postId: post.id
                )
            }
        } catch {
            errorMessage = "Yorum eklenirken bir hata oluştu: \(error.localizedDescription)"
        }
    }
}

struct CommentCell: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.username)
                    .fontWeight(.semibold)
                Text(comment.timestamp.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(comment.text)
                .font(.subheadline)
        }
    }
} 
