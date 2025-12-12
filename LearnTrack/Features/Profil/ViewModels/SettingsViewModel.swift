
import Foundation
import SwiftUI
import UserNotifications
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            // Notifier le changement de thème
            NotificationCenter.default.post(name: NSNotification.Name("DarkModeChanged"), object: isDarkMode)
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
            if notificationsEnabled {
                requestNotificationPermission()
            }
        }
    }
    
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    init() {
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        checkNotificationPermission()
    }
    
    /// Check current notification permission status
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermissionStatus = settings.authorizationStatus
                if settings.authorizationStatus == .authorized {
                    self?.notificationsEnabled = true
                }
            }
        }
    }
    
    /// Request notification permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.notificationsEnabled = true
                    self?.notificationPermissionStatus = .authorized
                } else {
                    self?.notificationsEnabled = false
                    self?.notificationPermissionStatus = .denied
                }
            }
        }
    }
    
    /// Open app settings for notifications
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0"
    }
    
    var buildNumber: String {
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "1"
    }
}

