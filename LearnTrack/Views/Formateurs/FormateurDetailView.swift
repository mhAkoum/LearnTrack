//
//  FormateurDetailView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct FormateurDetailView: View {
    let formateur: Formateur
    @ObservedObject var viewModel: FormateursViewModel
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    @State private var showingCopyConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    Text(formateur.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if !formateur.actif {
                        Text("Inactif")
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Contact Actions
                if formateur.telephone != nil || !formateur.email.isEmpty {
                    VStack(spacing: 12) {
                        if let telephone = formateur.telephone {
                            ContactActionButton(
                                icon: "phone.fill",
                                title: "Call",
                                color: .green,
                                action: {
                                    openPhoneApp(phoneNumber: telephone)
                                }
                            )
                            
                            ContactActionButton(
                                icon: "message.fill",
                                title: "SMS",
                                color: .blue,
                                action: {
                                    openSMSApp(phoneNumber: telephone)
                                }
                            )
                        }
                        
                        ContactActionButton(
                            icon: "envelope.fill",
                            title: "Email",
                            color: .blue,
                            action: {
                                openEmailApp(email: formateur.email)
                            }
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                // Details Section
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "envelope", title: "Email", value: formateur.email)
                    
                    if let telephone = formateur.telephone {
                        DetailRow(icon: "phone", title: "Téléphone", value: telephone)
                    }
                    
                    if let tarifJournalier = formateur.tarifJournalier {
                        DetailRow(icon: "eurosign.circle", title: "Tarif Journalier", value: String(format: "%.2f €", tarifJournalier))
                    }
                    
                    if let adresse = formateur.adresse {
                        DetailRow(icon: "mappin", title: "Adresse", value: adresse)
                    }
                    
                    if let ville = formateur.ville {
                        DetailRow(icon: "mappin", title: "Ville", value: ville)
                    }
                    
                    if let codePostal = formateur.codePostal {
                        DetailRow(icon: "number", title: "Code Postal", value: codePostal)
                    }
                    
                    if let specialites = formateur.specialites, !specialites.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.accentColor)
                                Text("Spécialités")
                                    .font(.headline)
                            }
                            Text(specialites.joined(separator: ", "))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let notes = formateur.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.accentColor)
                                Text("Notes")
                                    .font(.headline)
                            }
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Formateur")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEdit = true
                    }) {
                        Label("Modifier", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        // Copier dans le presse-papier (SHARE-05)
                        let text = formateurShareText()
                        ClipboardManager.shared.copyToClipboard(text)
                        showingCopyConfirmation = true
                    }) {
                        Label("Copier", systemImage: "doc.on.doc")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Copié !", isPresented: $showingCopyConfirmation) {
            Button("OK") { }
        } message: {
            Text("Les informations du formateur ont été copiées dans le presse-papier")
        }
        .sheet(isPresented: $showingEdit) {
            FormateurFormView(viewModel: viewModel, formateur: formateur)
        }
        .alert("Delete Formateur", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteFormateur(id: formateur.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete this formateur? This action cannot be undone.")
        }
    }
    
    private func openPhoneApp(phoneNumber: String) {
        // Nettoyer le numéro de téléphone (enlever espaces, tirets, parenthèses, points)
        var cleanedNumber = phoneNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "+", with: "")
        
        // Si le numéro commence par 0, le remplacer par l'indicatif français +33
        if cleanedNumber.hasPrefix("0") {
            cleanedNumber = "+33" + String(cleanedNumber.dropFirst())
        }
        
        // Encoder le numéro pour l'URL
        guard let encodedNumber = cleanedNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode phone number: \(phoneNumber)")
            return
        }
        
        // Créer l'URL tel:// pour ouvrir l'app téléphone
        guard let url = URL(string: "tel://\(encodedNumber)") else {
            print("❌ Failed to create URL for phone number: \(phoneNumber)")
            return
        }
        
        // Vérifier si l'URL peut être ouverte
        guard UIApplication.shared.canOpenURL(url) else {
            print("❌ Cannot open tel:// URL. This might not work on simulator.")
            return
        }
        
        // Ouvrir l'URL
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                print("❌ Failed to open phone app for: \(phoneNumber)")
            }
        }
    }
    
    private func openSMSApp(phoneNumber: String) {
        // Nettoyer le numéro de téléphone
        var cleanedNumber = phoneNumber
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "+", with: "")
        
        // Si le numéro commence par 0, le remplacer par l'indicatif français +33
        if cleanedNumber.hasPrefix("0") {
            cleanedNumber = "+33" + String(cleanedNumber.dropFirst())
        }
        
        // Encoder le numéro pour l'URL
        guard let encodedNumber = cleanedNumber.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode phone number for SMS: \(phoneNumber)")
            return
        }
        
        // Créer l'URL sms:// pour ouvrir l'app Messages
        guard let url = URL(string: "sms://\(encodedNumber)") else {
            print("❌ Failed to create SMS URL for: \(phoneNumber)")
            return
        }
        
        // Vérifier si l'URL peut être ouverte
        guard UIApplication.shared.canOpenURL(url) else {
            print("❌ Cannot open sms:// URL. This might not work on simulator.")
            return
        }
        
        // Ouvrir l'URL
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                print("❌ Failed to open SMS app for: \(phoneNumber)")
            }
        }
    }
    
    private func openEmailApp(email: String) {
        // Nettoyer et encoder l'email pour l'URL
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedEmail.isEmpty else {
            print("❌ Email is empty")
            return
        }
        
        // Encoder l'email pour l'URL
        guard let encodedEmail = trimmedEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Failed to encode email: \(email)")
            return
        }
        
        // Créer l'URL mailto: pour ouvrir l'app Mail
        guard let url = URL(string: "mailto:\(encodedEmail)") else {
            print("❌ Failed to create mailto URL for: \(email)")
            return
        }
        
        // Vérifier si l'URL peut être ouverte
        guard UIApplication.shared.canOpenURL(url) else {
            print("❌ Cannot open mailto: URL. This might not work on simulator.")
            return
        }
        
        // Ouvrir l'URL
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                print("❌ Failed to open email app for: \(email)")
            }
        }
    }
    
    private func formateurShareText() -> String {
        var text = "👨‍🏫 \(formateur.fullName)\n\n"
        text += "\(AppEmojis.email) Email: \(formateur.email)\n"
        if let telephone = formateur.telephone {
            text += "\(AppEmojis.phone) Téléphone: \(telephone)\n"
        }
        if let specialites = formateur.specialites, !specialites.isEmpty {
            text += "🎯 Spécialités: \(specialites.joined(separator: ", "))\n"
        }
        if let tarif = formateur.tarifJournalier {
            text += "\(AppEmojis.money) Tarif journalier: \(String(format: "%.2f €", tarif))\n"
        }
        if let adresse = formateur.adresse {
            text += "\(AppEmojis.location) Adresse: \(adresse)"
            if let ville = formateur.ville {
                text += ", \(ville)"
            }
            text += "\n"
        }
        return text
    }
}

// MARK: - Contact Action Button
struct ContactActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationView {
        FormateurDetailView(
            formateur: Formateur(
                id: 1,
                nom: "Doe",
                prenom: "John",
                email: "john@example.com",
                telephone: "+33123456789",
                specialites: ["iOS", "Swift"],
                tarifJournalier: 500.0,
                adresse: "123 Main St",
                ville: "Paris",
                codePostal: "75001",
                notes: "Expert iOS",
                actif: true
            ),
            viewModel: FormateursViewModel()
        )
    }
}

