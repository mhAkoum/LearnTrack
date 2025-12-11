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
                Section("Informations du client") {
                    TextField("Nom", text: $nom)
                }
                
                Section("Contact") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    TextField("Téléphone", text: $telephone)
                        .keyboardType(.phonePad)
                }
                
                Section("Adresse") {
                    TextField("Adresse", text: $adresse)
                    TextField("Ville", text: $ville)
                    TextField("Code Postal", text: $codePostal)
                        .keyboardType(.numberPad)
                }
                
                Section("Informations entreprise") {
                    TextField("SIRET", text: $siret)
                        .keyboardType(.numberPad)
                }
                
                Section("Contact entreprise") {
                    TextField("Nom du contact", text: $contactNom)
                    TextField("Email du contact", text: $contactEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    TextField("Téléphone du contact", text: $contactTelephone)
                        .keyboardType(.phonePad)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditMode ? "Edit Client" : "New Client")
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
