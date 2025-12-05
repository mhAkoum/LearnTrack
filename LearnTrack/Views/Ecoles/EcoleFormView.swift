//
//  EcoleFormView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct EcoleFormView: View {
    @ObservedObject var viewModel: EcolesViewModel
    let ecole: Ecole?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var nom: String = ""
    @State private var contactNom: String = ""
    @State private var contactEmail: String = ""
    @State private var contactTelephone: String = ""
    @State private var adresse: String = ""
    @State private var notes: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var isEditMode: Bool {
        ecole != nil
    }
    
    init(viewModel: EcolesViewModel, ecole: Ecole?) {
        self.viewModel = viewModel
        self.ecole = ecole
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations de l'école") {
                    TextField("Nom de l'école", text: $nom)
                }
                
                Section("Contact") {
                    TextField("Nom du contact", text: $contactNom)
                    TextField("Email", text: $contactEmail)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    TextField("Téléphone", text: $contactTelephone)
                        .keyboardType(.phonePad)
                }
                
                Section("Adresse") {
                    TextField("Adresse", text: $adresse)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditMode ? "Edit École" : "New École")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEcole()
                    }
                    .disabled(nom.isEmpty || viewModel.isLoading)
                }
            }
            .onAppear {
                if let ecole = ecole {
                    loadEcoleData(ecole)
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
    
    private func loadEcoleData(_ ecole: Ecole) {
        nom = ecole.nom
        contactNom = ecole.contact_nom ?? ""
        contactEmail = ecole.contact_email ?? ""
        contactTelephone = ecole.contact_telephone ?? ""
        adresse = ecole.adresse ?? ""
        notes = ecole.notes ?? ""
    }
    
    private func saveEcole() {
        // Validate
        guard !nom.isEmpty else {
            errorMessage = "Nom de l'école is required"
            showingError = true
            return
        }
        
        if !contactEmail.isEmpty && !contactEmail.isValidEmail {
            errorMessage = "Please enter a valid email address"
            showingError = true
            return
        }
        
        // Create or update ecole
        let ecoleToSave = Ecole(
            id: ecole?.id ?? UUID(),
            nom: nom,
            contact_nom: contactNom.isEmpty ? nil : contactNom,
            contact_email: contactEmail.isEmpty ? nil : contactEmail,
            contact_telephone: contactTelephone.isEmpty ? nil : contactTelephone,
            adresse: adresse.isEmpty ? nil : adresse,
            notes: notes.isEmpty ? nil : notes
        )
        
        Task {
            do {
                if isEditMode {
                    try await viewModel.updateEcole(ecoleToSave)
                } else {
                    try await viewModel.createEcole(ecoleToSave)
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
    EcoleFormView(viewModel: EcolesViewModel(), ecole: nil)
}
