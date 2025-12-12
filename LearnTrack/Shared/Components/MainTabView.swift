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
                    Label("Sessions", systemImage: "book.fill")
                }
                .badge(0)
            
            FormateursListView()
                .tabItem {
                    Label("Formateurs", systemImage: "person.2.fill")
                }
            
            ClientsListView()
                .tabItem {
                    Label("Clients", systemImage: "person.3.fill")
                }
            
            EcolesListView()
                .tabItem {
                    Label("Écoles", systemImage: "building.2.fill")
                }
            
            ProfilView()
                .tabItem {
                    Label("Profil", systemImage: "person.circle.fill")
                }
        }
        .accentColor(AppColors.primary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}

