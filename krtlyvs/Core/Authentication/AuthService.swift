//
//  AuthService.swift
//  krtlyvs
//
//  Created by Mirac Kar on 22.05.2025.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func login(withEmail email: String, password: String) async throws -> AuthDataResult {
        guard !email.isEmpty, !password.isEmpty else {
            throw NSError(domain: "AuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email ve şifre boş olamaz"])
        }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result
        } catch {
            print("🔴 Giriş hatası: \(error.localizedDescription)")
            throw error
        }
    }
    
    func register(withEmail email: String, password: String, username: String) async throws -> AuthDataResult {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            throw NSError(domain: "AuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Tüm alanları doldurun"])
        }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            // Kullanıcı profilini güncelle
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = username
            try await changeRequest.commitChanges()
            
            return result
        } catch {
            print("🔴 Kayıt hatası: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            print("🔴 Çıkış hatası: \(error.localizedDescription)")
            throw error
        }
    }
    
    func resetPassword(withEmail email: String) async throws {
        guard !email.isEmpty else {
            throw NSError(domain: "AuthService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Email boş olamaz"])
        }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            print("🔴 Şifre sıfırlama hatası: \(error.localizedDescription)")
            throw error
        }
    }
}
