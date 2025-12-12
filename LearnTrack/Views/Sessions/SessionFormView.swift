
import SwiftUI

struct SessionFormView: View {
    @ObservedObject var viewModel: SessionsViewModel
    let session: Session?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var titre: String = ""
    @State private var description: String = ""
    @State private var dateDebut: Date = Date()
    @State private var dateFin: Date = Date().addingTimeInterval(3600 * 8) // 8 hours later
    @State private var heureDebut: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var heureFin: Date = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var statut: String = "planifié"
    @State private var presentielDistanciel: String = "Présentiel"
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
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Titre de la session")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        TextField("Ex: Formation iOS", text: $titre)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Informations principales", systemImage: AppIcons.sessions)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.notes)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Date de début")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.calendar)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        DatePicker("", selection: $dateDebut, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Date de fin")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.calendar)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        DatePicker("", selection: $dateFin, displayedComponents: [.date])
                            .datePickerStyle(.compact)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Dates", systemImage: AppIcons.calendar)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Heure de début")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.clock)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        DatePicker("", selection: $heureDebut, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.compact)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Heure de fin")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.clock)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        DatePicker("", selection: $heureFin, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.compact)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Heures", systemImage: AppIcons.clock)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Mode")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.presentiel)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        Picker("Mode", selection: $presentielDistanciel) {
                            Label("Présentiel", systemImage: AppIcons.presentiel).tag("Présentiel")
                            Label("Distanciel", systemImage: AppIcons.distanciel).tag("Distanciel")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Mode de formation", systemImage: AppIcons.presentiel)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Statut")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.status)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        TextField("Ex: planifié", text: $statut)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Prix")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.money)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        TextField("Ex: 5000", text: $prix)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Nombre de participants")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.participants)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        TextField("Ex: 20", text: $nbParticipants)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Informations complémentaires", systemImage: AppIcons.info)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label {
                            Text("Notes")
                                .font(.headline)
                                .foregroundColor(AppColors.sessions)
                        } icon: {
                            Image(systemName: AppIcons.notes)
                                .foregroundColor(AppColors.sessions)
                                .font(.title3)
                        }
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Label("Notes", systemImage: AppIcons.notes)
                }
            }
            .navigationTitle(isEditMode ? "Modifier Session" : "Nouvelle Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
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
            .alert("Erreur", isPresented: $showingError) {
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
        // Convertir les heures string en Date
        if let heureDebutValue = session.heureDebut {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            if let date = timeFormatter.date(from: heureDebutValue) {
                heureDebut = date
            } else {
                // Essayer avec HH:mm
                timeFormatter.dateFormat = "HH:mm"
                if let date = timeFormatter.date(from: heureDebutValue) {
                    heureDebut = date
                }
            }
        }
        if let heureFinValue = session.heureFin {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"
            if let date = timeFormatter.date(from: heureFinValue) {
                heureFin = date
            } else {
                // Essayer avec HH:mm
                timeFormatter.dateFormat = "HH:mm"
                if let date = timeFormatter.date(from: heureFinValue) {
                    heureFin = date
                }
            }
        }
        statut = session.statut
        // Convertir "P" ou "D" en "Présentiel" ou "Distanciel" pour l'affichage
        if let mode = session.presentielDistanciel {
            if mode.uppercased() == "P" {
                presentielDistanciel = "Présentiel"
            } else if mode.uppercased() == "D" {
                presentielDistanciel = "Distanciel"
            } else {
                presentielDistanciel = mode
            }
        } else {
            presentielDistanciel = "Présentiel"
        }
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
            errorMessage = "Le titre est requis"
            showingError = true
            return
        }
        
        guard dateFin >= dateDebut else {
            errorMessage = "La date de fin doit être après ou égale à la date de début"
            showingError = true
            return
        }
        
        // Format dates to YYYY-MM-DD
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateDebutString = dateFormatter.string(from: dateDebut)
        let dateFinString = dateFormatter.string(from: dateFin)
        
        // Format times to HH:MM
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let heureDebutString = timeFormatter.string(from: heureDebut)
        let heureFinString = timeFormatter.string(from: heureFin)
        
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
                        heureDebut: heureDebutString,
                        heureFin: heureFinString,
                        clientId: nil, // TODO: Add client picker
                        ecoleId: nil,  // TODO: Add ecole picker
                        formateurId: nil, // TODO: Add formateur picker
                        nbParticipants: nbParticipantsValue,
                        statut: statut.isEmpty ? nil : statut,
                        prix: prixValue,
                        notes: notes.isEmpty ? nil : notes,
                        presentielDistanciel: presentielDistanciel
                    )
                    try await viewModel.updateSession(id: sessionId, sessionUpdate)
                } else {
                    // Create new session
                    let sessionCreate = SessionCreate(
                        titre: titre,
                        description: description.isEmpty ? nil : description,
                        dateDebut: dateDebutString,
                        dateFin: dateFinString,
                        heureDebut: heureDebutString,
                        heureFin: heureFinString,
                        clientId: nil, // TODO: Add client picker
                        ecoleId: nil,  // TODO: Add ecole picker
                        formateurId: nil, // TODO: Add formateur picker
                        nbParticipants: nbParticipantsValue,
                        statut: statut.isEmpty ? nil : statut,
                        prix: prixValue,
                        notes: notes.isEmpty ? nil : notes,
                        presentielDistanciel: presentielDistanciel
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

