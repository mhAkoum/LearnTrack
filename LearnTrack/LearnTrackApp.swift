//
//  LearnTrackApp.swift
//  LearnTrack
//
//  Created by mohmmad akoum on 04/12/2025.
//

import SwiftUI

@main
struct LearnTrackApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Configure Supabase on app launch
        SupabaseService.shared.configure()
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
            .task {
                // Test database connection on app launch
                await SupabaseService.shared.testConnection()
                // Check auth status on app launch
                await authViewModel.checkAuthStatus()
            }
        }
    }
}
