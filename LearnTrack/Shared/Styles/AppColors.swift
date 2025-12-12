//
//  AppColors.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

/// Palette de couleurs personnalisée pour LearnTrack
struct AppColors {
    // MARK: - Primary Colors
    static let primary = Color(red: 0.2, green: 0.4, blue: 0.8) // Bleu principal
    static let primaryLight = Color(red: 0.3, green: 0.5, blue: 0.9)
    static let primaryDark = Color(red: 0.1, green: 0.3, blue: 0.7)
    
    // MARK: - Accent Colors
    static let accent = Color(red: 0.9, green: 0.4, blue: 0.2) // Orange/Corail
    static let accentLight = Color(red: 1.0, green: 0.5, blue: 0.3)
    static let accentDark = Color(red: 0.8, green: 0.3, blue: 0.1)
    
    // MARK: - Feature Colors
    static let sessions = Color(red: 0.4, green: 0.7, blue: 0.9) // Bleu clair
    static let formateurs = Color(red: 0.6, green: 0.4, blue: 0.9) // Violet
    static let clients = Color(red: 0.9, green: 0.6, blue: 0.3) // Orange
    static let ecoles = Color(red: 0.3, green: 0.8, blue: 0.6) // Vert
    static let profil = Color(red: 0.9, green: 0.5, blue: 0.7) // Rose
    
    // MARK: - Status Colors
    static let success = Color(red: 0.2, green: 0.7, blue: 0.4) // Vert
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.2) // Jaune/Orange
    static let error = Color(red: 0.9, green: 0.3, blue: 0.3) // Rouge
    static let info = Color(red: 0.3, green: 0.6, blue: 0.9) // Bleu
    
    // MARK: - Background Colors
    static let backgroundLight = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let backgroundDark = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let cardBackground = Color(red: 1.0, green: 1.0, blue: 1.0)
    static let cardBackgroundDark = Color(red: 0.15, green: 0.15, blue: 0.2)
    
    // MARK: - Gradient Colors
    static let gradientStart = Color(red: 0.2, green: 0.4, blue: 0.8)
    static let gradientEnd = Color(red: 0.4, green: 0.6, blue: 0.9)
    
    static let gradientAccentStart = Color(red: 0.9, green: 0.4, blue: 0.2)
    static let gradientAccentEnd = Color(red: 1.0, green: 0.6, blue: 0.4)
}

/// Extensions pour les gradients
extension LinearGradient {
    static var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [AppColors.gradientAccentStart, AppColors.gradientAccentEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

/// Emojis pour les différentes sections
struct AppEmojis {
    static let sessions = "📅"
    static let formateurs = "👨‍🏫"
    static let clients = "👥"
    static let ecoles = "🏫"
    static let profil = "👤"
    
    static let add = "➕"
    static let edit = "✏️"
    static let delete = "🗑️"
    static let search = "🔍"
    static let filter = "🔽"
    static let settings = "⚙️"
    static let logout = "🚪"
    static let save = "💾"
    static let cancel = "❌"
    static let success = "✅"
    static let error = "❌"
    static let warning = "⚠️"
    static let info = "ℹ️"
    
    static let email = "📧"
    static let phone = "📞"
    static let location = "📍"
    static let calendar = "📆"
    static let clock = "🕐"
    static let money = "💰"
    static let notes = "📝"
    static let star = "⭐"
}

