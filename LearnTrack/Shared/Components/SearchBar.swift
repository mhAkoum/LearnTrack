//
//  SearchBar.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

// MARK: - Search Bar
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Rechercher..."
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: AppIcons.search)
                .foregroundColor(AppColors.primary)
                .font(.title3)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [AppColors.primary.opacity(0.1), AppColors.accent.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.primary.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    SearchBar(text: .constant(""))
        .padding()
}

