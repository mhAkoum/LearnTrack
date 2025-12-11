//
//  MainTabView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            SessionsListView()
                .tabItem {
                    Label("Sessions", systemImage: "calendar")
                }
            
            FormateursListView()
                .tabItem {
                    Label("Formateurs", systemImage: "person.2")
                }
            
            ClientsListView()
                .tabItem {
                    Label("Clients", systemImage: "person.crop.circle")
                }
            
            EcolesListView()
                .tabItem {
                    Label("Écoles", systemImage: "building.2")
                }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if let user = authViewModel.currentUser {
                        Text("Signed in as: \(user.fullName)")
                            .font(.caption)
                    }
                    
                    Button(role: .destructive, action: {
                        Task {
                            await authViewModel.logout()
                        }
                    }) {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                } label: {
                    Image(systemName: "person.circle")
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}

