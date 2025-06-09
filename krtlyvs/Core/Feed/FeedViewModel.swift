//
//  FeedViewModel.swift
//  krtlyvs
//
//  Created by Mirac Kar on 21.05.2025.
//

import Foundation
import FirebaseFirestore
import Firebase

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        Task {
            await fetchPosts()
        }
    }
    
    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            posts = try await PostService.shared.fetchAllPosts()
        } catch {
            errorMessage = "Gönderiler yüklenirken bir hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func refreshPosts() async {
        await fetchPosts()
    }
}
