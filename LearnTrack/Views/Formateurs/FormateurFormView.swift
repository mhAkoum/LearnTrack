//
//  FormateurFormView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct FormateurFormView: View {
    @ObservedObject var viewModel: FormateursViewModel
    let formateur: Formateur?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var nom: String = ""
    @State private var prenom: String = ""
    @State private var email: String = ""
    @State private var telephone: String = ""
    @State private var type: String = "interne"
    @State private var specialites: String = ""
    @State private var notes: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var isEditMode: Bool {
        formateur != nil
    }
    
    init(viewModel: FormateursViewModel, formateur: Formateur?) {
        self.viewModel = viewModel
        self.formateur = formateur
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
                
                Section("Type") {
                    Picker("Type", selection: $type) {
                        Text("Interne").tag("interne")
                        Text("Externe").tag("externe")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Spécialités") {
                    TextField("Spécialités", text: $specialites)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditMode ? "Edit Formateur" : "New Formateur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveFormateur()
                    }
                    .disabled(nom.isEmpty || prenom.isEmpty || viewModel.isLoading)
                }
            }
            .onAppear {
                if let formateur = formateur {
                    loadFormateurData(formateur)
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
    
    private func loadFormateurData(_ formateur: Formateur) {
        nom = formateur.nom
        prenom = formateur.prenom
        email = formateur.email ?? ""
        telephone = formateur.telephone ?? ""
        type = formateur.type  // Use computed property
        specialites = formateur.specialites ?? ""  // Use computed property
        notes = formateur.notes ?? ""  // Use computed property
    }
    
    private func saveFormateur() {
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
        
        // Create or update formateur
        let formateurToSave = Formateur(
            id: formateur?.id ?? 0,  // 0 for new records, database will auto-increment
            nom: nom,
            prenom: prenom,
            email: email.isEmpty ? nil : email,
            telephone: telephone.isEmpty ? nil : telephone,
            specialite: specialites.isEmpty ? nil : specialites,
            exterieur: type == "externe"  // Convert type string to boolean
        )
        
        Task {
            do {
                if isEditMode {
                    try await viewModel.updateFormateur(formateurToSave)
                } else {
                    try await viewModel.createFormateur(formateurToSave)
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
    FormateurFormView(viewModel: FormateursViewModel(), formateur: nil)
}

