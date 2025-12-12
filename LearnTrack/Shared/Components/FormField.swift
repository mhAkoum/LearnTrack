//
//  FormField.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct FormField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var color: Color = AppColors.primary
    var noAutocapitalization: Bool = false
    var disableAutocorrection: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
            }
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(noAutocapitalization ? .none : .sentences)
                .autocorrectionDisabled(disableAutocorrection)
        }
        .padding(.vertical, 4)
    }
}

struct FormTextEditor: View {
    let icon: String
    let title: String
    @Binding var text: String
    var minHeight: CGFloat = 100
    var color: Color = AppColors.primary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
            }
            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    Form {
        Section {
            FormField(icon: AppIcons.person, title: "Nom", placeholder: "Entrez le nom", text: .constant(""))
            FormField(icon: AppIcons.email, title: "Email", placeholder: "email@example.com", text: .constant(""), keyboardType: .emailAddress)
            FormTextEditor(icon: AppIcons.notes, title: "Notes", text: .constant(""))
        }
    }
}

