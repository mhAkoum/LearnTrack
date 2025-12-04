//
//  SessionFormView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct SessionFormView: View {
    @ObservedObject var viewModel: SessionsViewModel
    let session: Session?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var module: String = ""
    @State private var dateDebut: Date = Date()
    @State private var dateFin: Date = Date().addingTimeInterval(3600 * 8) // 8 hours later
    @State private var presentielDistanciel: String = "Présentiel"
    @State private var prix: String = ""
    @State private var nda: String = ""
    @State private var statut: String = ""
    @State private var notes: String = ""
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var isEditMode: Bool {
        session != nil
    }
    
    init(viewModel: SessionsViewModel, session: Session?) {
        self.viewModel = viewModel
        self.session = session
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Module") {
                    TextField("Nom du module", text: $module)
                }
                
                Section("Dates") {
                    DatePicker("Date de début", selection: $dateDebut, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Date de fin", selection: $dateFin, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Type") {
                    Picker("Type", selection: $presentielDistanciel) {
                        Text("Présentiel").tag("Présentiel")
                        Text("Distanciel").tag("Distanciel")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Informations") {
                    TextField("Prix (€)", text: $prix)
                        .keyboardType(.decimalPad)
                    
                    TextField("NDA", text: $nda)
                    
                    TextField("Statut", text: $statut)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(isEditMode ? "Edit Session" : "New Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSession()
                    }
                    .disabled(module.isEmpty || viewModel.isLoading)
                }
            }
            .onAppear {
                if let session = session {
                    loadSessionData(session)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func loadSessionData(_ session: Session) {
        module = session.module
        if let date = session.dateDebut {
            dateDebut = date
        }
        if let date = session.dateFin {
            dateFin = date
        }
        presentielDistanciel = session.presentiel_distanciel
        if let prixValue = session.prix {
            prix = String(format: "%.2f", prixValue)
        }
        nda = session.nda ?? ""
        statut = session.statut ?? ""
        notes = session.notes ?? ""
    }
    
    private func saveSession() {
        // Validate
        guard !module.isEmpty else {
            errorMessage = "Module name is required"
            showingError = true
            return
        }
        
        guard dateFin > dateDebut else {
            errorMessage = "End date must be after start date"
            showingError = true
            return
        }
        
        // Format dates to ISO 8601
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateDebutString = formatter.string(from: dateDebut)
        let dateFinString = formatter.string(from: dateFin)
        
        // Parse prix
        let prixValue = Double(prix.isEmpty ? "0" : prix.replacingOccurrences(of: ",", with: "."))
        
        // Create or update session
        let sessionToSave = Session(
            id: session?.id ?? UUID(),
            date_debut: dateDebutString,
            date_fin: dateFinString,
            module: module,
            formateur_id: nil, // TODO: Add formateur picker in Phase 4
            client_id: nil,    // TODO: Add client picker in Phase 5
            ecole_id: nil,     // TODO: Add ecole picker in Phase 6
            presentiel_distanciel: presentielDistanciel,
            prix: prixValue,
            nda: nda.isEmpty ? nil : nda,
            statut: statut.isEmpty ? nil : statut,
            notes: notes.isEmpty ? nil : notes
        )
        
        Task {
            do {
                if isEditMode {
                    try await viewModel.updateSession(sessionToSave)
                } else {
                    try await viewModel.createSession(sessionToSave)
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
    SessionFormView(viewModel: SessionsViewModel(), session: nil)
}

