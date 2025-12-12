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
                .badge(0)
            
            FormateursListView()
                .tabItem {
                    Label("Formateurs", systemImage: "person.2")
                }
            
            ClientsListView()
                .tabItem {
                    Label("Clients", systemImage: "building")
                }
            
            EcolesListView()
                .tabItem {
                    Label("Écoles", systemImage: "graduationcap")
                }
            
            ProfilView()
                .tabItem {
                    Label("Profil", systemImage: "gearshape")
                }
        }
        .accentColor(AppColors.primary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}

