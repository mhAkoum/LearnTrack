
import SwiftUI

@main
struct LearnTrackApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        // Synchroniser avec UserDefaults au démarrage
        isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                        .environmentObject(authViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DarkModeChanged"))) { notification in
                if let newValue = notification.object as? Bool {
                    isDarkMode = newValue
                }
            }
            .task {
                // Check auth status on app launch
                await authViewModel.checkAuthStatus()
            }
        }
    }
}

