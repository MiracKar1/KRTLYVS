//
//  FeedView.swift
//  krtlyvs
//
//  Created by Mirac Kar on 1.06.2025.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    @State private var selectedTab = 0
    
    let currentUserUid: String

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach($viewModel.posts) { $post in
                            FeedCell(post: $post, currentUserUid: currentUserUid)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 12)
                }
                .background(Color(.systemGroupedBackground))
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .navigationTitle("Ana Sayfa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("KRTLYVS")
                        .font(.title3)
                        .fontWeight(.bold)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Gelecekte mesaj sayfasına geçiş yapılabilir
                    } label: {
                        Image(systemName: "paperplane")
                            .imageScale(.large)
                    }
                }
            }
            .refreshable {
                await viewModel.refreshPosts()
            }
            .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Tamam") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchPosts()
            }
        }
    }
}
