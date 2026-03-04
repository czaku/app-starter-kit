import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: AppTokens.Spacing.lg) {
                Text("Welcome!")
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppTokens.Color.textPrimary)

                Text("Your app is ready.")
                    .font(.body)
                    .foregroundStyle(AppTokens.Color.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTokens.Color.background.ignoresSafeArea())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticsHelper.impact(.light)
                        showLogoutConfirmation = true
                    } label: {
                        Image(systemName: "person.circle")
                            .foregroundStyle(AppTokens.Color.textPrimary)
                            .accessibilityLabel("Account")
                    }
                }
            }
            .confirmationDialog(
                "Sign out of your account?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    HapticsHelper.notification(.warning)
                    appState.logout()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }
}
