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
                // Check auth status on app launch
                await authViewModel.checkAuthStatus()
            }
        }
    }
}

