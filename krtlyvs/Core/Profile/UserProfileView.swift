//
//  UserProfileView.swift
//  krtlyvs
//
//  Created by Mirac Kar on 16.05.2025.
//

import SwiftUI

struct UserProfileView: View {
    let user: User
    private let gridItems = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ProfileHeaderView(user: user)
                UserStatsView()
                FollowButton()
                Divider().padding(.top)
                PostGridSection()
            }
        }
        .navigationTitle(user.username)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Parçalanmış Alt View'lar

struct ProfileHeaderView: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 8) {
            if !user.profileImageUrl.isEmpty {
                if let url = URL(string: user.profileImageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 90, height: 90)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 90, height: 90)
            }
            
            Text(user.username)
                .font(.title2)
                .fontWeight(.semibold)
            
            if !user.bio.isEmpty {
                Text(user.bio)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .padding(.top)
    }
}

struct UserStatsView: View {
    var body: some View {
        HStack(spacing: 16) {
            StatItem(number: "0", label: "Gönderi")
            StatItem(number: "156", label: "Takipçi")
            StatItem(number: "125", label: "Takip")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct FollowButton: View {
    var body: some View {
        Button(action: {
            // Takip et/çık işlemi yapılacak
        }) {
            Text("Takip Et")
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

struct PostGridSection: View {
    private let gridItems = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gönderiler")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: gridItems, spacing: 1) {
                ForEach(0..<12, id: \.self) { index in
                    Image("post_\(index)")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipped()
                }
            }
        }
    }
}
//#Preview {
//    UserProfileView(user: User.MOCK_USERS.first!)
//}
