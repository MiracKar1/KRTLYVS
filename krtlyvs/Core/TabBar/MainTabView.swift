import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var posts: [Post] = []
    
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                switch selectedTab {
                case 0:
                    if let uid = authViewModel.currentUser?.id {
                        FeedView(currentUserUid: uid)
                    } else {
                        ProgressView("Yükleniyor...")
                    }
                case 1:
                    SearchView()
                case 2:
                    if let user = authViewModel.currentUser {
                        UploadPostView(posts: $posts, currentUser: user)
                    } else {
                        ProgressView("Yükleniyor...")
                    }
                case 3:
                    if let uid = authViewModel.currentUser?.id {
                        NotificationsView()
                    } else {
                        ProgressView("Yükleniyor...")
                    }
                case 4:
                    if let userId = authViewModel.currentUser?.id {
                        ProfileView(userId: userId)
                    } else {
                        ProgressView("Profil yükleniyor...")
                    }
                default:
                    if let uid = authViewModel.currentUser?.id {
                        FeedView(currentUserUid: uid)
                    } else {
                        ProgressView("Yükleniyor...")
                    }
                }
            }

            // Custom Tab Bar
            HStack {
                tabBarItem(image: "house.fill", index: 0)
                Spacer()
                tabBarItem(image: "magnifyingglass", index: 1)
                Spacer()
                tabBarItem(image: "plus.app.fill", index: 2)
                Spacer()
                tabBarItem(image: "bell.fill", index: 3)
                Spacer()
                tabBarItem(image: "person.crop.circle", index: 4)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 5)
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    private func tabBarItem(image: String, index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .foregroundColor(selectedTab == index ? .blue : .gray)
        }
    }
}
