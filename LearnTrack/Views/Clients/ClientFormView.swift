//
//  ClientFormView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct ClientFormView: View {
    @ObservedObject var viewModel: ClientsViewModel
    let client: Client?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var nom: String = ""
    @State private var email: String = ""
    @State private var telephone: String = ""
    @State private var adresse: String = ""
    @State private var ville: String = ""
    @State private var codePostal: String = ""
    @State private var siret: String = ""
    @State private var contactNom: String = ""
    @State private var contactEmail: String = ""
    @State private var contactTelephone: String = ""
    @State private var notes: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var isEditMode: Bool {
        client != nil
    }
    
    init(viewModel: ClientsViewModel, client: Client?) {
        self.viewModel = viewModel
        self.client = client
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    FormField(emoji: "🏢", title: "Nom", placeholder: "Ex: Acme Corp", text: $nom, color: AppColors.clients)
                } header: {
                    Text("\(AppEmojis.clients) Informations du client")
                }
                
                Section {
                    FormField(emoji: AppEmojis.email, title: "Email", placeholder: "contact@acme.com", text: $email, keyboardType: .emailAddress, color: AppColors.clients, noAutocapitalization: true, disableAutocorrection: true)
                    
                    FormField(emoji: AppEmojis.phone, title: "Téléphone", placeholder: "0123456789", text: $telephone, keyboardType: .phonePad, color: AppColors.clients)
                } header: {
                    Text("\(AppEmojis.phone) Contact")
                }
                
                Section {
                    FormField(emoji: AppEmojis.location, title: "Adresse", placeholder: "Ex: 123 rue de la Paix", text: $adresse, color: AppColors.clients)
                    FormField(emoji: AppEmojis.location, title: "Ville", placeholder: "Ex: Paris", text: $ville, color: AppColors.clients)
                    FormField(emoji: AppEmojis.location, title: "Code Postal", placeholder: "Ex: 75001", text: $codePostal, keyboardType: .numberPad, color: AppColors.clients)
                } header: {
                    Text("\(AppEmojis.location) Adresse")
                }
                
                Section {
                    FormField(emoji: "🏢", title: "SIRET", placeholder: "Ex: 12345678901234", text: $siret, keyboardType: .numberPad, color: AppColors.clients)
                } header: {
                    Text("🏢 Informations entreprise")
                }
                
                Section {
                    FormField(emoji: "👤", title: "Nom du contact", placeholder: "Ex: Jean Dupont", text: $contactNom, color: AppColors.clients)
                    FormField(emoji: AppEmojis.email, title: "Email du contact", placeholder: "jean.dupont@acme.com", text: $contactEmail, keyboardType: .emailAddress, color: AppColors.clients, noAutocapitalization: true, disableAutocorrection: true)
                    FormField(emoji: AppEmojis.phone, title: "Téléphone du contact", placeholder: "0123456789", text: $contactTelephone, keyboardType: .phonePad, color: AppColors.clients)
                } header: {
                    Text("👤 Contact entreprise")
                }
                
                Section {
                    FormTextEditor(emoji: AppEmojis.notes, title: "Notes", text: $notes, color: AppColors.clients)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditMode ? "\(AppEmojis.edit) Modifier Client" : "\(AppEmojis.add) Nouveau Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveClient()
                    }
                    .disabled(nom.isEmpty || viewModel.isLoading)
                }
            }
            .onAppear {
                if let client = client {
                    loadClientData(client)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    private func loadClientData(_ client: Client) {
        nom = client.nom
        email = client.email ?? ""
        telephone = client.telephone ?? ""
        adresse = client.adresse ?? ""
        ville = client.ville ?? ""
        codePostal = client.codePostal ?? ""
        siret = client.siret ?? ""
        contactNom = client.contactNom ?? ""
        contactEmail = client.contactEmail ?? ""
        contactTelephone = client.contactTelephone ?? ""
        notes = client.notes ?? ""
    }
    
    private func saveClient() {
        // Validate
        guard !nom.isEmpty else {
            errorMessage = "Nom is required"
            showingError = true
            return
        }
        
        if !email.isEmpty && !email.isValidEmail {
            errorMessage = "Please enter a valid email address"
            showingError = true
            return
        }
        
        if !contactEmail.isEmpty && !contactEmail.isValidEmail {
            errorMessage = "Please enter a valid contact email address"
            showingError = true
            return
        }
        
        Task {
            do {
                if isEditMode, let clientId = client?.id {
                    // Update existing client
                    let clientUpdate = ClientUpdate(
                        nom: nom,
                        email: email.isEmpty ? nil : email,
                        telephone: telephone.isEmpty ? nil : telephone,
                        adresse: adresse.isEmpty ? nil : adresse,
                        ville: ville.isEmpty ? nil : ville,
                        codePostal: codePostal.isEmpty ? nil : codePostal,
                        siret: siret.isEmpty ? nil : siret,
                        contactNom: contactNom.isEmpty ? nil : contactNom,
                        contactEmail: contactEmail.isEmpty ? nil : contactEmail,
                        contactTelephone: contactTelephone.isEmpty ? nil : contactTelephone,
                        notes: notes.isEmpty ? nil : notes,
                        actif: nil
                    )
                    try await viewModel.updateClient(id: clientId, clientUpdate)
                } else {
                    // Create new client
                    let clientCreate = ClientCreate(
                        nom: nom,
                        email: email.isEmpty ? nil : email,
                        telephone: telephone.isEmpty ? nil : telephone,
                        adresse: adresse.isEmpty ? nil : adresse,
                        ville: ville.isEmpty ? nil : ville,
                        codePostal: codePostal.isEmpty ? nil : codePostal,
                        siret: siret.isEmpty ? nil : siret,
                        contactNom: contactNom.isEmpty ? nil : contactNom,
                        contactEmail: contactEmail.isEmpty ? nil : contactEmail,
                        contactTelephone: contactTelephone.isEmpty ? nil : contactTelephone,
                        notes: notes.isEmpty ? nil : notes
                    )
                    try await viewModel.createClient(clientCreate)
                }
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showingError = true
            }
        }
    }
}

#Preview {
    ClientFormView(viewModel: ClientsViewModel(), client: nil)
}
