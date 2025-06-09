//
//  SearchView.swift
//  krtlyvs
//
//  Created by Mirac Kar on 9.03.2025.
//

import SwiftUI
import FirebaseFirestore

struct SearchView: View {
    @State private var searchText = ""
    @State private var users: [User] = []
    @State private var posts: [Post] = []

    private let gridItems = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 🔍 Arama aktifse kullanıcıları göster
                    if !searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(filteredUsers) { user in
                                NavigationLink(destination: UserProfileView(user: user)) {
                                    HStack(spacing: 12) {
                                        profileImage(for: user)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(user.username)
                                                .fontWeight(.semibold)
                                                .foregroundColor(Color("buttonTextColor"))
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top, 10)
                    } else {
                        // 🖼️ Post grid
                        LazyVGrid(columns: gridItems, spacing: 2) {
                            ForEach(posts) { post in
                                postImage(for: post)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Keşfet")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Kullanıcı ara")
            .onAppear {
                Task {
                    await fetchInitialData()
                }
            }
        }
    }

    private var filteredUsers: [User] {
        users.filter {
            $0.username.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func fetchInitialData() async {
        do {
            async let fetchedUsers = UserService.fetchAllUsers()
            async let fetchedPosts = PostService.shared.fetchAllPosts()

            self.users = try await fetchedUsers
            self.posts = try await fetchedPosts
        } catch {
            print("Veri alınamadı: \(error.localizedDescription)")
        }
    }

    @ViewBuilder
    private func profileImage(for user: User) -> some View {
        if !user.profileImageUrl.isEmpty {
            if let url = URL(string: user.profileImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    default:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 44, height: 44)
                    }
                }
            }
        } else {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 44, height: 44)
        }
    }
    
    @ViewBuilder
    private func postImage(for post: Post) -> some View {
        if let url = URL(string: post.imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .clipped()
                default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                }
            }
        }
    }
}
//#Preview {
//    SearchView()
//}
