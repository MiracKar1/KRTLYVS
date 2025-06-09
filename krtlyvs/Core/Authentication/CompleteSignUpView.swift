import SwiftUI

struct CompleteSignUpView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoading = false
    @State private var showMainView = false
    @State private var errorMessage: String?
    @State private var showErrorAlert = false
    
    // Kullanıcı bilgilerini AuthViewModel'den alıyoruz
    private var email: String {
        authViewModel.email
    }
    
    private var password: String {
        authViewModel.password
    }
    
    private var username: String {
        authViewModel.username
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    VStack(spacing: 12) {
                        Text("Kartal Yuvasına Hoşgeldin!")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Kayıt işlemini tamamlamak için aşağıdaki butona dokun.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    } else {
                        Button {
                            Task {
                                isLoading = true
                                do {
                                    try await authViewModel.createUser(
                                        withEmail: email,
                                        password: password,
                                        username: username
                                    )
                                    isLoading = false
                                    showMainView = true
                                } catch {
                                    isLoading = false
                                    errorMessage = error.localizedDescription
                                    showErrorAlert = true
                                }
                            }
                        } label: {
                            Text("Kaydı Tamamla")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }

                    NavigationLink(
                        destination: MainTabView().navigationBarBackButtonHidden(true),
                        isActive: $showMainView,
                        label: { EmptyView() }
                    )

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
            .alert("Hata", isPresented: $showErrorAlert, actions: {
                Button("Tamam", role: .cancel) {}
            }, message: {
                Text(errorMessage ?? "Bilinmeyen bir hata oluştu.")
            })
        }
    }
}

//#Preview {
//    CompleteSignUpView()
//       .environmentObject(AuthViewModel())
//}
