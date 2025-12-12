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
                            emoji: "👤",
                            title: "Nom",
                            value: user.fullName,
                            color: AppColors.profil
                        )
                        
                        UserInfoRow(
                            emoji: AppEmojis.email,
                            title: "Email",
                            value: user.email,
                            color: AppColors.info
                        )
                        
                        UserInfoRow(
                            emoji: "🔑",
                            title: "Rôle",
                            value: user.role.capitalized,
                            color: user.isAdmin ? AppColors.accent : AppColors.primary
                        )
                    } header: {
                        HStack {
                            Text("👤")
                            Text("Informations utilisateur")
                        }
                        .font(.headline)
                        .foregroundColor(AppColors.profil)
                    }
                }
                
                // Section: Préférences d'affichage
                Section {
                    Toggle(isOn: $settingsViewModel.isDarkMode) {
                        HStack {
                            Text(settingsViewModel.isDarkMode ? "🌙" : "☀️")
                                .font(.title3)
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
                    HStack {
                        Text("🎨")
                        Text("Préférences d'affichage")
                    }
                    .font(.headline)
                    .foregroundColor(AppColors.primary)
                }
                
                // Section: Gestion des notifications
                Section {
                    Toggle(isOn: $settingsViewModel.notificationsEnabled) {
                        HStack {
                            Text("🔔")
                                .font(.title3)
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
                                Text("⚙️")
                                    .font(.title3)
                                    .frame(width: 30)
                                Text("Ouvrir les paramètres")
                                    .foregroundColor(AppColors.accent)
                                    .fontWeight(.medium)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("🔔")
                        Text("Gestion des notifications")
                    }
                    .font(.headline)
                    .foregroundColor(AppColors.accent)
                } footer: {
                    if settingsViewModel.notificationPermissionStatus == .denied {
                        HStack {
                            Text("⚠️")
                            Text("Les notifications sont désactivées. Activez-les dans les paramètres de l'appareil.")
                        }
                        .font(.caption)
                    }
                }
                
                // Section: À propos
                Section {
                    HStack {
                        Text("ℹ️")
                            .font(.title3)
                            .frame(width: 30)
                        Text("Version")
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(settingsViewModel.appVersion) (\(settingsViewModel.buildNumber))")
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("📱")
                            .font(.title3)
                            .frame(width: 30)
                        Text("LearnTrack")
                            .fontWeight(.medium)
                        Spacer()
                        Text("Gestion de formations")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    HStack {
                        Text("ℹ️")
                        Text("À propos de l'application")
                    }
                    .font(.headline)
                    .foregroundColor(AppColors.info)
                }
                
                // Section: Déconnexion
                Section {
                    Button(role: .destructive, action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Text(AppEmojis.logout)
                                .font(.title3)
                                .frame(width: 30)
                            Text("Déconnexion")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("\(AppEmojis.profil) Profil")
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
    let emoji: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                Text(emoji)
                    .font(.title3)
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

