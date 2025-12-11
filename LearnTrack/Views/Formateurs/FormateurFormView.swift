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
                
                Section("Spécialités") {
                    TextField("Spécialités (séparées par des virgules)", text: $specialites)
                }
                
                Section("Tarif") {
                    TextField("Tarif journalier (€)", text: $tarifJournalier)
                        .keyboardType(.decimalPad)
                }
                
                Section("Adresse") {
                    TextField("Adresse", text: $adresse)
                    TextField("Ville", text: $ville)
                    TextField("Code Postal", text: $codePostal)
                        .keyboardType(.numberPad)
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
                    .disabled(nom.isEmpty || prenom.isEmpty || email.isEmpty || viewModel.isLoading)
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
            errorMessage = "Nom, Prénom, and Email are required"
            showingError = true
            return
        }
        
        if !email.isValidEmail {
            errorMessage = "Please enter a valid email address"
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

