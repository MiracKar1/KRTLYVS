import Foundation
import SwiftUI
import FirebaseAuth

struct UserProfileContainerView: View {
    @State private var user: User?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Yükleniyor...")
            } else if let user = user {
                UserProfileView(user: user)
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                Text("Kullanıcı bulunamadı.")
                    .foregroundColor(.red)
            }
        }
        .task {
            await loadUser()
        }
    }
    
    func loadUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            errorMessage = "Giriş yapılmamış."
            isLoading = false
            return
        }
        
        do {
            let fetchedUser = try await UserService.fetchUserAsync(withUid: uid)
            user = fetchedUser
        } catch {
            print("Kullanıcı çekme hatası: \(error.localizedDescription)")
            errorMessage = "Kullanıcı verileri alınamadı: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
