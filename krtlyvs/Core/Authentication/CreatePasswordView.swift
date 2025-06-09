import SwiftUI

struct CreatePasswordView: View {
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateNext = false // Bu değişken navigasyonu kontrol eder
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Text("Şifre Oluştur")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Hesabın için güçlü bir şifre belirle.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    SecureField("Şifre", text: $password)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .autocapitalization(.none)
                        .padding(.horizontal)

                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                            .transition(.opacity)
                    }

                    Button {
                        if password.count < 6 {
                            errorMessage = "Şifreniz en az 6 karakter olmalı."
                            showError = true
                        } else {
                            showError = false
                            authViewModel.password = password
                            navigateNext = true
                        }
                    } label: {
                        Text("Devam Et")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }

                    NavigationLink(destination: CreateUsernameView().navigationBarBackButtonHidden(true),
                                   isActive: $navigateNext) {
                        EmptyView()
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.accentColor)
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}

//#Preview {
//    CreatePasswordView()
//        .environmentObject(AuthViewModel())
//}
