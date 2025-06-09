//
//  SessionStore.swift
//  krtlyvs
//
//  Created by Mirac Kar on 22.05.2025.
//

import Foundation
import FirebaseAuth
import Combine

class SessionStore: ObservableObject {
    @Published var isLoggedIn: Bool = Auth.auth().currentUser != nil

    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Çıkış yapılamadı: \(error.localizedDescription)")
        }
    }
}
