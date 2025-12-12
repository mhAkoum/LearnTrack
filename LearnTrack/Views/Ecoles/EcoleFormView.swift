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
                Section {
                    FormField(emoji: AppEmojis.ecoles, title: "Nom de l'école", placeholder: "Ex: EPITA", text: $nom, color: AppColors.ecoles)
                } header: {
                    Text("\(AppEmojis.ecoles) Informations de l'école")
                }
                
                Section {
                    FormField(emoji: AppEmojis.location, title: "Adresse", placeholder: "Ex: 14-16 rue Voltaire", text: $adresse, color: AppColors.ecoles)
                    FormField(emoji: AppEmojis.location, title: "Ville", placeholder: "Ex: Paris", text: $ville, color: AppColors.ecoles)
                    FormField(emoji: AppEmojis.location, title: "Code Postal", placeholder: "Ex: 94270", text: $codePostal, keyboardType: .numberPad, color: AppColors.ecoles)
                } header: {
                    Text("\(AppEmojis.location) Adresse")
                }
                
                Section {
                    FormField(emoji: "👤", title: "Responsable", placeholder: "Ex: Jean Dupont", text: $responsableNom, color: AppColors.ecoles)
                    FormField(emoji: AppEmojis.email, title: "Email", placeholder: "contact@ecole.fr", text: $email, keyboardType: .emailAddress, color: AppColors.ecoles, noAutocapitalization: true, disableAutocorrection: true)
                    
                    FormField(emoji: AppEmojis.phone, title: "Téléphone", placeholder: "0123456789", text: $telephone, keyboardType: .phonePad, color: AppColors.ecoles)
                } header: {
                    Text("\(AppEmojis.phone) Contact")
                }
                
                Section {
                    FormField(emoji: "👥", title: "Capacité", placeholder: "Ex: 100", text: $capacite, keyboardType: .numberPad, color: AppColors.ecoles)
                } header: {
                    Text("👥 Informations complémentaires")
                }
                
                Section {
                    FormTextEditor(emoji: AppEmojis.notes, title: "Notes", text: $notes, color: AppColors.ecoles)
                } header: {
                    Text("\(AppEmojis.notes) Notes")
                }
            }
            .navigationTitle(isEditMode ? "\(AppEmojis.edit) Modifier École" : "\(AppEmojis.add) Nouvelle École")
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
