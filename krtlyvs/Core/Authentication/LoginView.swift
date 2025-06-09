//
//  LoginView.swift
//  krtlyvs
//
//  Created by Mirac Kar on 1.05.2025.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var isLoggedIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()

                    Text("KRTLYVS")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("buttonTextColor"))

                    VStack(spacing: 16) {
                        TextField("E-posta adresinizi girin", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .modifier(KrtlyvsTextFieldModifier())

                        SecureFieldWithButton("Şifrenizi Girin", text: $password)
                    }
                    .padding(.horizontal)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button {
                        login()
                    } label: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(8)
                        } else {
                            Text("Giriş Yap")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(8)
                        }
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)

                    Button {
                        print("Şifremi unuttum")
                    } label: {
                        Text("Şifremi Unuttum")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal)

                    HStack {
                        Rectangle()
                            .frame(height: 0.5)
                        Text("veya")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Rectangle()
                            .frame(height: 0.5)
                    }
                    .padding(.horizontal)

                    Spacer()

                    Divider()

                    NavigationLink {
                        AddEmailView()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Hesabınız yok mu?")
                            Text("Kayıt Ol")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(Color("buttonTextColor"))
                        .font(.footnote)
                    }
                    .padding(.bottom)

                    NavigationLink(destination: MainTabView()
                        .navigationBarBackButtonHidden(true),
                                   isActive: $isLoggedIn) {
                        EmptyView()
                    }
                }
                .padding()
            }
        }
    }

    private func login() {
        errorMessage = nil
        isLoading = true

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoading = false

            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}

//#Preview {
//    LoginView()
//        .environmentObject(AuthViewModel())
//}
