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
    @State private var prenom: String = ""
    @State private var email: String = ""
    @State private var telephone: String = ""
    @State private var entreprise: String = ""
    @State private var adresse: String = ""
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
                Section("Informations personnelles") {
                    TextField("Nom", text: $nom)
                    TextField("Prénom", text: $prenom)
                }
                
                Section("Contact") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    TextField("Téléphone", text: $telephone)
                        .keyboardType(.phonePad)
                }
                
                Section("Entreprise") {
                    TextField("Nom de l'entreprise", text: $entreprise)
                    TextField("Adresse", text: $adresse)
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
                    .disabled(nom.isEmpty || prenom.isEmpty || viewModel.isLoading)
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
        prenom = client.prenom
        email = client.email ?? ""
        telephone = client.telephone ?? ""
        entreprise = client.entreprise ?? ""
        adresse = client.adresse ?? ""
        notes = client.notes ?? ""
    }
    
    private func saveClient() {
        // Validate
        guard !nom.isEmpty, !prenom.isEmpty else {
            errorMessage = "Nom and Prénom are required"
            showingError = true
            return
        }
        
        if !email.isEmpty && !email.isValidEmail {
            errorMessage = "Please enter a valid email address"
            showingError = true
            return
        }
        
        // Create or update client
        let clientToSave = Client(
            id: client?.id ?? UUID(),
            nom: nom,
            prenom: prenom,
            email: email.isEmpty ? nil : email,
            telephone: telephone.isEmpty ? nil : telephone,
            entreprise: entreprise.isEmpty ? nil : entreprise,
            adresse: adresse.isEmpty ? nil : adresse,
            notes: notes.isEmpty ? nil : notes
        )
        
        Task {
            do {
                if isEditMode {
                    try await viewModel.updateClient(clientToSave)
                } else {
                    try await viewModel.createClient(clientToSave)
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
