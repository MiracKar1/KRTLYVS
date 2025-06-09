import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?

    private let gridItems = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)

    init(userId: String) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(userId: userId))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileImageSection()
                    statsSection()
                    editProfileButton()
                    postsSection()
                }
                .padding(.top)
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        signOut()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage) // Burada "image:" kullanılmalı
            }
            .onChange(of: selectedImage) { newImage in
                if let newImage = newImage {
                    uploadProfileImage(newImage)
                }
            }
        }
    }

    @ViewBuilder
    private func profileImageSection() -> some View {
        VStack(spacing: 8) {
            if let url = URL(string: viewModel.profileImageUrl), !viewModel.profileImageUrl.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 90, height: 90)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    case .failure:
                        defaultProfileImage()
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                defaultProfileImage()
            }

            Button("Profil Fotoğrafını Değiştir") {
                showingImagePicker = true
            }
            .font(.footnote)

            Text(viewModel.username)
                .font(.title2)
                .fontWeight(.semibold)

            Text(".")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.top)
    }

    private func defaultProfileImage() -> some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 90, height: 90)
            .foregroundColor(.gray)
    }

    private func statsSection() -> some View {
        HStack(spacing: 16) {
            StatItem(number: "\(viewModel.postCount)", label: "Gönderi")
            StatItem(number: "\(viewModel.followersCount)", label: "Takipçi")
            StatItem(number: "\(viewModel.followingCount)", label: "Takip")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func editProfileButton() -> some View {
        Button {
            // Profili düzenleme sayfasına yönlendirme için kod buraya
        } label: {
            Text("Profili Düzenle")
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }

    private func postsSection() -> some View {
        VStack(alignment: .leading) {
            Text("Gönderiler")
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: gridItems, spacing: 1) {
                ForEach(viewModel.posts) { post in
                    if let url = URL(string: post.imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 120)
                                .clipped()
                        } placeholder: {
                            ProgressView()
                                .frame(height: 120)
                        }
                    } else {
                        Color.gray.frame(height: 120)
                    }
                }
            }
        }
    }

    private func signOut() {
        authViewModel.signOut()
    }

    private func uploadProfileImage(_ image: UIImage) {
        guard let uid = authViewModel.currentUser?.id else { return }

        UserService.uploadProfileImage(image, forUid: uid) { result in
            switch result {
            case .success(let urlString):
                print("Profil resmi yüklendi: \(urlString)")
                DispatchQueue.main.async {
                    viewModel.profileImageUrl = urlString
                }
            case .failure(let error):
                print("Profil resmi yüklenirken hata: \(error.localizedDescription)")
            }
        }
    }
}

struct StatItem: View {
    let number: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
