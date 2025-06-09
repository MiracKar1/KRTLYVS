import SwiftUI

struct AddEmailView: View {
    @State private var email = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateNext = false // Bu ile navigation kontrolü
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
                        Text("Hoş Geldin!")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("E-posta adresini girerek devam et.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    TextField("E-posta adresi", text: $email)
                        .padding()
                        .background(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .keyboardType(.emailAddress)
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
                        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            errorMessage = "Lütfen e-posta adresinizi girin."
                            showError = true
                        } else if !isValidEmail(email) {
                            errorMessage = "Geçerli bir e-posta adresi girin."
                            showError = true
                        } else {
                            showError = false
                            authViewModel.email = email
                            navigateNext = true // Doğruysa yönlendir
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

                    NavigationLink(destination: CreatePasswordView().navigationBarBackButtonHidden(true),
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

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegEx).evaluate(with: email)
    }
}

//#Preview {
//    AddEmailView()
//        .environmentObject(AuthViewModel())
//}
