import SwiftUI
import SwiftData

struct AuthGateView: View {
    @Query private var profiles: [UserProfile]

    private var loggedInProfile: UserProfile? {
        profiles.first { $0.isLoggedIn }
    }

    var body: some View {
        Group {
            if loggedInProfile != nil {
                RootTabView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            } else {
                LoginView(hasExistingAccount: !profiles.isEmpty)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: loggedInProfile?.persistentModelID)
    }
}
