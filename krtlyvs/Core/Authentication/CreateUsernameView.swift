import SwiftUI

struct CreateUsernameView: View {
    @State private var username = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateNext = false // Navigasyon kontrolü için
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
                        Text("Kullanıcı Adı Belirle")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("Profilin için bir kullanıcı adı oluştur.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    TextField("Kullanıcı adı", text: $username)
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
                    }

                    Button {
                        if username.count < 3 {
                            errorMessage = "Kullanıcı adı en az 3 karakter olmalı."
                            showError = true
                        } else {
                            showError = false
                            authViewModel.username = username
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

                    NavigationLink(destination: CompleteSignUpView().navigationBarBackButtonHidden(true),
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
//   CreateUsernameView()
//        .environmentObject(AuthViewModel())
//}
