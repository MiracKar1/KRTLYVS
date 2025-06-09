import SwiftUI
import Firebase
import PhotosUI

struct ProfileImageUploadView: View {
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var isUploading = false
    
    let currentUserUid: String
    
    @State private var profileImageUrl: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if let urlString = profileImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                         .scaledToFill()
                         .frame(width: 120, height: 120)
                         .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 120, height: 120)
                }
            } else if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
            }
            
            Button("Profil Resmi Seç") {
                showingImagePicker = true
            }
            .disabled(isUploading)
            
            if selectedImage != nil {
                Button("Yükle") {
                    Task {
                        await uploadImage()
                    }
                }
                .disabled(isUploading)
            }
            
            if isUploading {
                ProgressView("Yükleniyor...")
            }
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            ProfileImagePicker(selectedImage: $selectedImage)
        }
        .onAppear {
            Task {
                await fetchCurrentProfileImage()
            }
        }
    }
    
    func uploadImage() async {
        guard let image = selectedImage else { return }
        
        isUploading = true
        
        do {
            let url = try await StorageService.shared.uploadProfileImage(image, userUid: currentUserUid)
            profileImageUrl = url
            
            try await UserService.updateProfileImageURL(url, uid: currentUserUid) { error in
                if let error = error {
                    print("Firestore güncelleme hatası: \(error.localizedDescription)")
                } else {
                    print("Profil resmi URL'si güncellendi.")
                }
            }
        } catch {
            print("Fotoğraf yüklenemedi: \(error.localizedDescription)")
        }
        
        isUploading = false
    }
    
    func fetchCurrentProfileImage() async {
        do {
            let docRef = Firestore.firestore().collection("users").document(currentUserUid)
            let snapshot = try await docRef.getDocument()
            if let data = snapshot.data() {
                profileImageUrl = data["profileImageUrl"] as? String
            }
        } catch {
            print("Profil resmi alınamadı: \(error.localizedDescription)")
        }
    }
}

// MARK: - Preview

//#Preview {
    // currentUserUid parametresini örnek olarak veriyoruz, gerçek uygulamada FirebaseAuth ile al
//  ProfileImageUploadView(currentUserUid: "exampleUid123")
//}
