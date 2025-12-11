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
    @State private var adresse: String = ""
    @State private var ville: String = ""
    @State private var codePostal: String = ""
    @State private var telephone: String = ""
    @State private var email: String = ""
    @State private var responsableNom: String = ""
    @State private var capacite: String = ""
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
                
                Section("Adresse") {
                    TextField("Adresse", text: $adresse)
                    TextField("Ville", text: $ville)
                    TextField("Code Postal", text: $codePostal)
                        .keyboardType(.numberPad)
                }
                
                Section("Contact") {
                    TextField("Responsable", text: $responsableNom)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    TextField("Téléphone", text: $telephone)
                        .keyboardType(.phonePad)
                }
                
                Section("Informations complémentaires") {
                    TextField("Capacité", text: $capacite)
                        .keyboardType(.numberPad)
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
        adresse = ecole.adresse ?? ""
        ville = ecole.ville ?? ""
        codePostal = ecole.codePostal ?? ""
        telephone = ecole.telephone ?? ""
        email = ecole.email ?? ""
        responsableNom = ecole.responsableNom ?? ""
        if let capaciteValue = ecole.capacite {
            capacite = "\(capaciteValue)"
        }
        notes = ecole.notes ?? ""
    }
    
    private func saveEcole() {
        // Validate
        guard !nom.isEmpty else {
            errorMessage = "Nom de l'école is required"
            showingError = true
            return
        }
        
        if !email.isEmpty && !email.isValidEmail {
            errorMessage = "Please enter a valid email address"
            showingError = true
            return
        }
        
        // Parse capacite
        let capaciteValue = capacite.isEmpty ? nil : Int(capacite)
        
        Task {
            do {
                if isEditMode, let ecoleId = ecole?.id {
                    // Update existing ecole
                    let ecoleUpdate = EcoleUpdate(
                        nom: nom,
                        adresse: adresse.isEmpty ? nil : adresse,
                        ville: ville.isEmpty ? nil : ville,
                        codePostal: codePostal.isEmpty ? nil : codePostal,
                        telephone: telephone.isEmpty ? nil : telephone,
                        email: email.isEmpty ? nil : email,
                        responsableNom: responsableNom.isEmpty ? nil : responsableNom,
                        capacite: capaciteValue,
                        notes: notes.isEmpty ? nil : notes,
                        actif: nil
                    )
                    try await viewModel.updateEcole(id: ecoleId, ecoleUpdate)
                } else {
                    // Create new ecole
                    let ecoleCreate = EcoleCreate(
                        nom: nom,
                        adresse: adresse.isEmpty ? nil : adresse,
                        ville: ville.isEmpty ? nil : ville,
                        codePostal: codePostal.isEmpty ? nil : codePostal,
                        telephone: telephone.isEmpty ? nil : telephone,
                        email: email.isEmpty ? nil : email,
                        responsableNom: responsableNom.isEmpty ? nil : responsableNom,
                        capacite: capaciteValue,
                        notes: notes.isEmpty ? nil : notes
                    )
                    try await viewModel.createEcole(ecoleCreate)
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
