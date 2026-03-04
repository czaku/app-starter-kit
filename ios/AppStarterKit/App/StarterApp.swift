import SwiftUI

// MARK: - Firebase / Crashlytics
// TODO: Uncomment after adding GoogleService-Info.plist to the Xcode project target.
//       Steps:
//         1. Download GoogleService-Info.plist from the Firebase console.
//         2. Drag it into the AppStarterKit target (Copy Items if Needed = YES).
//         3. Add the Firebase SDK via Swift Package Manager (https://github.com/firebase/firebase-ios-sdk).
//         4. Uncomment the lines below.
// import Firebase
// FirebaseApp.configure()

extension Notification.Name {
    /// Posted when the app handles a deep-link containing an OTP code.
    /// `userInfo` key: `"code"` → `String`
    static let deepLinkOTPReceived = Notification.Name("DeepLinkOTPReceived")
}

@main
struct AppStarterKit: App {
    @State private var appState = AppState()
    @State private var toastManager = ToastManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(toastManager)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }

    // MARK: - Deep-link handling

    /// Handles two URL shapes:
    ///   • Custom scheme:  `appstarterkit://auth/verify?code=XXXXXX`
    ///   • Universal link: `https://yourapp.com/auth/verify?code=XXXXXX`
    private func handleDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        // Accept both the custom scheme and the universal-link host/path.
        let isCustomScheme = url.scheme?.lowercased() == "appstarterkit"
        let isUniversalLink = (url.scheme == "https" || url.scheme == "http")
            && url.path == "/auth/verify"

        guard isCustomScheme || isUniversalLink else { return }

        // The path for custom scheme looks like "/auth/verify"; host is "auth".
        let isAuthVerify: Bool
        if isCustomScheme {
            isAuthVerify = url.host?.lowercased() == "auth" && url.path == "/verify"
        } else {
            isAuthVerify = true // already checked path above
        }

        guard isAuthVerify,
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
              !code.isEmpty else {
            return
        }

        NotificationCenter.default.post(
            name: .deepLinkOTPReceived,
            object: nil,
            userInfo: ["code": code]
        )
    }
}
