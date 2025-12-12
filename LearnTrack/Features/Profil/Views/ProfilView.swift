//
//  ProfilView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct ProfilView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // Section: Informations utilisateur
                if let user = authViewModel.currentUser {
                    Section {
                        UserInfoRow(
                            icon: AppIcons.person,
                            title: "Nom",
                            value: user.fullName,
                            color: AppColors.profil
                        )
                        
                        UserInfoRow(
                            icon: AppIcons.email,
                            title: "Email",
                            value: user.email,
                            color: AppColors.info
                        )
                        
                        UserInfoRow(
                            icon: "key.fill",
                            title: "Rôle",
                            value: user.role.capitalized,
                            color: user.isAdmin ? AppColors.accent : AppColors.primary
                        )
                    } header: {
                        Label("Informations utilisateur", systemImage: AppIcons.person)
                            .font(.headline)
                            .foregroundColor(AppColors.profil)
                    }
                }
                
                // Section: Préférences d'affichage
                Section {
                    Toggle(isOn: $settingsViewModel.isDarkMode) {
                        HStack {
                            Image(systemName: settingsViewModel.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .font(.title3)
                                .foregroundColor(settingsViewModel.isDarkMode ? AppColors.primary : .orange)
                                .frame(width: 30)
                            Text("Mode sombre")
                                .fontWeight(.medium)
                        }
                    }
                    .tint(AppColors.primary)
                    .onChange(of: settingsViewModel.isDarkMode) { oldValue, newValue in
                        // Le thème sera appliqué via l'environnement
                    }
                } header: {
                    Label("Préférences d'affichage", systemImage: "paintpalette.fill")
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                }
                
                // Section: Gestion des notifications
                Section {
                    Toggle(isOn: $settingsViewModel.notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.title3)
                                .foregroundColor(AppColors.accent)
                                .frame(width: 30)
                            Text("Notifications")
                                .fontWeight(.medium)
                        }
                    }
                    .tint(AppColors.accent)
                    
                    if settingsViewModel.notificationPermissionStatus == .denied {
                        Button(action: {
                            settingsViewModel.openAppSettings()
                        }) {
                            HStack {
                                Image(systemName: AppIcons.settings)
                                    .font(.title3)
                                    .foregroundColor(AppColors.accent)
                                    .frame(width: 30)
                                Text("Ouvrir les paramètres")
                                    .foregroundColor(AppColors.accent)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                } header: {
                    Label("Gestion des notifications", systemImage: "bell.fill")
                        .font(.headline)
                        .foregroundColor(AppColors.accent)
                } footer: {
                    if settingsViewModel.notificationPermissionStatus == .denied {
                        HStack(spacing: 6) {
                            Image(systemName: AppIcons.warning)
                                .font(.caption)
                            Text("Les notifications sont désactivées. Activez-les dans les paramètres de l'appareil.")
                        }
                        .font(.caption)
                    }
                }
                
                // Section: À propos
                Section {
                    HStack {
                        Image(systemName: AppIcons.info)
                            .font(.title3)
                            .foregroundColor(AppColors.info)
                            .frame(width: 30)
                        Text("Version")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(settingsViewModel.appVersion) (\(settingsViewModel.buildNumber))")
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Image(systemName: "iphone")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .frame(width: 30)
                        Text("LearnTrack")
                            .fontWeight(.medium)
                        Spacer()
                        Text("Gestion de formations")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Label("À propos de l'application", systemImage: AppIcons.info)
                        .font(.headline)
                        .foregroundColor(AppColors.info)
                }
                
                // Section: Déconnexion
                Section {
                    Button(role: .destructive, action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: AppIcons.logout)
                                .font(.title3)
                                .frame(width: 30)
                            Text("Déconnexion")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Profil")
            .alert("Déconnexion", isPresented: $showingLogoutAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Déconnexion", role: .destructive) {
                    Task {
                        await authViewModel.logout()
                    }
                }
            } message: {
                Text("Êtes-vous sûr de vouloir vous déconnecter ?")
            }
        }
    }
}

// MARK: - User Info Row
struct UserInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            Text(title)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ProfilView()
        .environmentObject(AuthViewModel())
}

