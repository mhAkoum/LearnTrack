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
    @State private var specialites: String = ""
    @State private var tarifJournalier: String = ""
    @State private var adresse: String = ""
    @State private var ville: String = ""
    @State private var codePostal: String = ""
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
                Section {
                    FormField(icon: AppIcons.person, title: "Nom", placeholder: "Ex: Dupont", text: $nom, color: AppColors.formateurs)
                    FormField(icon: AppIcons.person, title: "Prénom", placeholder: "Ex: Jean", text: $prenom, color: AppColors.formateurs)
                } header: {
                    Label("Informations personnelles", systemImage: AppIcons.formateurs)
                }
                
                Section {
                    FormField(icon: AppIcons.email, title: "Email", placeholder: "jean.dupont@example.com", text: $email, keyboardType: .emailAddress, color: AppColors.formateurs, noAutocapitalization: true, disableAutocorrection: true)
                    
                    FormField(icon: AppIcons.phone, title: "Téléphone", placeholder: "0123456789", text: $telephone, keyboardType: .phonePad, color: AppColors.formateurs)
                } header: {
                    Label("Contact", systemImage: AppIcons.phone)
                }
                
                Section {
                    FormField(icon: AppIcons.star, title: "Spécialités", placeholder: "iOS, Swift, UIKit (séparées par des virgules)", text: $specialites, color: AppColors.formateurs)
                } header: {
                    Label("Spécialités", systemImage: AppIcons.star)
                }
                
                Section {
                    FormField(icon: AppIcons.money, title: "Tarif journalier", placeholder: "Ex: 500", text: $tarifJournalier, keyboardType: .decimalPad, color: AppColors.formateurs)
                } header: {
                    Label("Tarif", systemImage: AppIcons.money)
                }
                
                Section {
                    FormField(icon: AppIcons.location, title: "Adresse", placeholder: "Ex: 123 rue de la Paix", text: $adresse, color: AppColors.formateurs)
                    FormField(icon: AppIcons.location, title: "Ville", placeholder: "Ex: Paris", text: $ville, color: AppColors.formateurs)
                    FormField(icon: AppIcons.location, title: "Code Postal", placeholder: "Ex: 75001", text: $codePostal, keyboardType: .numberPad, color: AppColors.formateurs)
                } header: {
                    Label("Adresse", systemImage: AppIcons.location)
                }
                
                Section {
                    FormTextEditor(icon: AppIcons.notes, title: "Notes", text: $notes, color: AppColors.formateurs)
                } header: {
                    Label("Notes", systemImage: AppIcons.notes)
                }
            }
            .navigationTitle(isEditMode ? "Modifier Formateur" : "Nouveau Formateur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveFormateur()
                    }
                    .disabled(nom.isEmpty || prenom.isEmpty || email.isEmpty || viewModel.isLoading)
                }
            }
            .onAppear {
                if let formateur = formateur {
                    loadFormateurData(formateur)
                }
            }
            .alert("Erreur", isPresented: $showingError) {
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
        email = formateur.email
        telephone = formateur.telephone ?? ""
        specialites = formateur.specialites?.joined(separator: ", ") ?? ""
        if let tarif = formateur.tarifJournalier {
            tarifJournalier = String(format: "%.2f", tarif)
        }
        adresse = formateur.adresse ?? ""
        ville = formateur.ville ?? ""
        codePostal = formateur.codePostal ?? ""
        notes = formateur.notes ?? ""
    }
    
    private func saveFormateur() {
        // Validate
        guard !nom.isEmpty, !prenom.isEmpty, !email.isEmpty else {
            errorMessage = "Le nom, le prénom et l'email sont requis"
            showingError = true
            return
        }
        
        if !email.isValidEmail {
            errorMessage = "Veuillez entrer une adresse email valide"
            showingError = true
            return
        }
        
        // Validate phone number if provided
        if !telephone.isEmpty && !telephone.isValidPhone {
            errorMessage = "Le numéro de téléphone doit contenir exactement 10 chiffres"
            showingError = true
            return
        }
        
        // Parse specialites (comma-separated string to array)
        let specialitesArray = specialites.isEmpty ? nil : specialites
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        // Parse tarifJournalier
        let tarifValue = tarifJournalier.isEmpty ? nil : Double(tarifJournalier.replacingOccurrences(of: ",", with: "."))
        
        Task {
            do {
                if isEditMode, let formateurId = formateur?.id {
                    // Update existing formateur
                    let formateurUpdate = FormateurUpdate(
                        nom: nom,
                        prenom: prenom,
                        email: email,
                        telephone: telephone.isEmpty ? nil : telephone,
                        specialites: specialitesArray,
                        tarifJournalier: tarifValue,
                        adresse: adresse.isEmpty ? nil : adresse,
                        ville: ville.isEmpty ? nil : ville,
                        codePostal: codePostal.isEmpty ? nil : codePostal,
                        notes: notes.isEmpty ? nil : notes,
                        actif: nil
                    )
                    try await viewModel.updateFormateur(id: formateurId, formateurUpdate)
                } else {
                    // Create new formateur
                    let formateurCreate = FormateurCreate(
                        nom: nom,
                        prenom: prenom,
                        email: email,
                        telephone: telephone.isEmpty ? nil : telephone,
                        specialites: specialitesArray,
                        tarifJournalier: tarifValue,
                        adresse: adresse.isEmpty ? nil : adresse,
                        ville: ville.isEmpty ? nil : ville,
                        codePostal: codePostal.isEmpty ? nil : codePostal,
                        notes: notes.isEmpty ? nil : notes
                    )
                    try await viewModel.createFormateur(formateurCreate)
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

