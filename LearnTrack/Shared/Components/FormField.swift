//
//  FormField.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct FormField: View {
    let emoji: String
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
                Text(emoji)
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
    let emoji: String
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
                Text(emoji)
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
            FormField(emoji: "👤", title: "Nom", placeholder: "Entrez le nom", text: .constant(""))
            FormField(emoji: "📧", title: "Email", placeholder: "email@example.com", text: .constant(""), keyboardType: .emailAddress)
            FormTextEditor(emoji: "📝", title: "Notes", text: .constant(""))
        }
    }
}

