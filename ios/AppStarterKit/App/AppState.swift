import Foundation

@Observable
class AppState {
    var isAuthenticated: Bool = false
    var currentUser: AppUser? = nil
    let forceUpdateChecker = ForceUpdateChecker()
    let networkMonitor = NetworkMonitor()

    /// Guards against double-tap or concurrent logout calls.
    private(set) var isLoggingOut: Bool = false

    @MainActor
    func logout() {
        guard !isLoggingOut else { return }
        isLoggingOut = true
        KeychainHelper.shared.clearAll()
        isAuthenticated = false
        currentUser = nil
        isLoggingOut = false
    }
}
