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
    
    @State private var titre: String = ""
    @State private var description: String = ""
    @State private var dateDebut: Date = Date()
    @State private var dateFin: Date = Date().addingTimeInterval(3600 * 8) // 8 hours later
    @State private var heureDebut: String = ""
    @State private var heureFin: String = ""
    @State private var statut: String = "planifié"
    @State private var prix: String = ""
    @State private var nbParticipants: String = ""
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
                Section("Titre") {
                    TextField("Titre de la session", text: $titre)
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 80)
                }
                
                Section("Dates") {
                    DatePicker("Date de début", selection: $dateDebut, displayedComponents: [.date])
                    DatePicker("Date de fin", selection: $dateFin, displayedComponents: [.date])
                }
                
                Section("Heures") {
                    TextField("Heure de début (HH:MM:SS)", text: $heureDebut)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("Heure de fin (HH:MM:SS)", text: $heureFin)
                        .keyboardType(.numbersAndPunctuation)
                }
                
                Section("Informations") {
                    TextField("Statut", text: $statut)
                    
                    TextField("Prix (€)", text: $prix)
                        .keyboardType(.decimalPad)
                    
                    TextField("Nombre de participants", text: $nbParticipants)
                        .keyboardType(.numberPad)
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
                    .disabled(titre.isEmpty || viewModel.isLoading)
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
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    private func loadSessionData(_ session: Session) {
        titre = session.titre
        description = session.description ?? ""
        if let date = session.dateDebutDate {
            dateDebut = date
        }
        if let date = session.dateFinDate {
            dateFin = date
        }
        heureDebut = session.heureDebut ?? ""
        heureFin = session.heureFin ?? ""
        statut = session.statut
        if let prixValue = session.prix {
            prix = String(format: "%.2f", prixValue)
        }
        if let nb = session.nbParticipants {
            nbParticipants = "\(nb)"
        }
        notes = session.notes ?? ""
    }
    
    private func saveSession() {
        // Validate
        guard !titre.isEmpty else {
            errorMessage = "Titre is required"
            showingError = true
            return
        }
        
        guard dateFin >= dateDebut else {
            errorMessage = "End date must be after or equal to start date"
            showingError = true
            return
        }
        
        // Format dates to YYYY-MM-DD
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateDebutString = dateFormatter.string(from: dateDebut)
        let dateFinString = dateFormatter.string(from: dateFin)
        
        // Parse prix and nbParticipants
        let prixValue = prix.isEmpty ? nil : Double(prix.replacingOccurrences(of: ",", with: "."))
        let nbParticipantsValue = nbParticipants.isEmpty ? nil : Int(nbParticipants)
        
        Task {
            do {
                if isEditMode, let sessionId = session?.id {
                    // Update existing session
                    let sessionUpdate = SessionUpdate(
                        titre: titre,
                        description: description.isEmpty ? nil : description,
                        dateDebut: dateDebutString,
                        dateFin: dateFinString,
                        heureDebut: heureDebut.isEmpty ? nil : heureDebut,
                        heureFin: heureFin.isEmpty ? nil : heureFin,
                        clientId: nil, // TODO: Add client picker
                        ecoleId: nil,  // TODO: Add ecole picker
                        formateurId: nil, // TODO: Add formateur picker
                        nbParticipants: nbParticipantsValue,
                        statut: statut.isEmpty ? nil : statut,
                        prix: prixValue,
                        notes: notes.isEmpty ? nil : notes
                    )
                    try await viewModel.updateSession(id: sessionId, sessionUpdate)
                } else {
                    // Create new session
                    let sessionCreate = SessionCreate(
                        titre: titre,
                        description: description.isEmpty ? nil : description,
                        dateDebut: dateDebutString,
                        dateFin: dateFinString,
                        heureDebut: heureDebut.isEmpty ? nil : heureDebut,
                        heureFin: heureFin.isEmpty ? nil : heureFin,
                        clientId: nil, // TODO: Add client picker
                        ecoleId: nil,  // TODO: Add ecole picker
                        formateurId: nil, // TODO: Add formateur picker
                        nbParticipants: nbParticipantsValue,
                        statut: statut.isEmpty ? nil : statut,
                        prix: prixValue,
                        notes: notes.isEmpty ? nil : notes
                    )
                    try await viewModel.createSession(sessionCreate)
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

