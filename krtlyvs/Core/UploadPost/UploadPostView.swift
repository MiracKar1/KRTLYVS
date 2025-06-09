import SwiftUI
import PhotosUI
import FirebaseStorage
import FirebaseFirestore

struct UploadPostView: View {
    @Binding var posts: [Post]
    let currentUser: User

    @State private var caption: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    @State private var isUploading: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            HStack {
                Button("İptal") {
                    dismiss()
                }
                .foregroundColor(.red)

                Spacer()

                Text("Gönderi Paylaş")
                    .font(.headline)

                Spacer()

                Button("Paylaş") {
                    uploadPost()
                }
                .disabled(selectedUIImage == nil || caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isUploading)
                .foregroundColor((selectedUIImage == nil || caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isUploading) ? .gray : .blue)
            }
            .padding()

            Divider()

            HStack(alignment: .top, spacing: 12) {
                if !currentUser.profileImageUrl.isEmpty {
                    if let url = URL(string: currentUser.profileImageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                }

                TextEditor(text: $caption)
                    .frame(minHeight: 100)
                    .padding(4)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
            }
            .padding(.horizontal)

            if let uiImage = selectedUIImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .cornerRadius(12)
                    .padding()
            }

            Spacer()

            PhotosPicker(selection: $selectedImage, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Fotoğraf Seç")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding(.horizontal)

            if isUploading {
                ProgressView("Yükleniyor...")
                    .padding()
            }
        }
        .onChange(of: selectedImage) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedUIImage = image
                }
            }
        }
    }

    private func uploadPost() {
        guard let image = selectedUIImage,
              let imageData = image.jpegData(compressionQuality: 0.5) else { return }

        isUploading = true

        let fileName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("post_images/\(fileName).jpg")

        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Fotoğraf yükleme hatası: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    isUploading = false
                }
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Download URL alınamadı: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        isUploading = false
                    }
                    return
                }

                guard let imageUrl = url?.absoluteString else {
                    print("Download URL alınamadı.")
                    DispatchQueue.main.async {
                        isUploading = false
                    }
                    return
                }

                let postId = UUID().uuidString
                let timestamp = Timestamp(date: Date())

                let postData: [String: Any] = [
                    "id": postId,
                    "ownerUid": currentUser.id,
                    "caption": caption,
                    "likes": [String](),
                    "imageUrl": imageUrl,
                    "timestamp": timestamp,
                    "comments": [String]()
                ]

                let db = Firestore.firestore()
                db.collection("posts").document(postId).setData(postData) { error in
                    if let error = error {
                        print("Firestore kaydı hatası: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            isUploading = false
                        }
                        return
                    }

                    let post = Post(
                        id: postId,
                        ownerUid: currentUser.id,
                        caption: caption,
                        imageUrl: imageUrl,
                        timestamp: Date(),
                        likes: [],
                        comments: []
                    )

                    DispatchQueue.main.async {
                        posts.insert(post, at: 0)
                        caption = ""
                        selectedUIImage = nil
                        selectedImage = nil
                        isUploading = false
                        dismiss()
                    }
                }
            }
        }
    }
}

//#Preview {
//    @State static var mockPosts: [Post] = []
//    return UploadPostView(posts: $mockPosts, currentUser: User(
//        id: "user123",
//        username: "kartalUser",
//        profileImageUrl: "",
//        fullName: nil,
//        bio: nil,
//        email: ""
//    ))
//}
