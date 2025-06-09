import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""

    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            errorMessage = "Giriş yapılırken bir hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func createUser(withEmail email: String, password: String, username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let user = User(
                id: result.user.uid,
                email: email,
                username: username,
                profileImageUrl: "",
                bio: "",
                isVerified: false
            )
            
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            
            await fetchUser()
        } catch {
            errorMessage = "Kullanıcı oluşturulurken bir hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            errorMessage = "Çıkış yapılırken bir hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await user.delete()
            self.userSession = nil
            self.currentUser = nil
        } catch {
            errorMessage = "Hesap silinirken bir hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            self.currentUser = try await UserService.fetchUserAsync(withUid: uid)
        } catch {
            errorMessage = "Kullanıcı bilgileri yüklenirken bir hata oluştu: \(error.localizedDescription)"
        }
    }
    
    func resetPassword(withEmail email: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = "Şifre sıfırlama bağlantısı gönderilirken bir hata oluştu: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
