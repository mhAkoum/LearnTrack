//
//  SessionDetailView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct SessionDetailView: View {
    let session: Session
    @ObservedObject var viewModel: SessionsViewModel
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var showingCopyConfirmation = false
    @State private var ecoleName: String? = nil
    @State private var clientName: String? = nil
    @State private var formateurName: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    Text(session.titre)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(session.statut)
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.2))
                        .foregroundColor(.accentColor)
                        .cornerRadius(8)
                    
                    if let description = session.description, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Details Section
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "calendar", title: "Date de début", value: session.formattedDateDebut)
                    DetailRow(icon: "calendar", title: "Date de fin", value: session.formattedDateFin)
                    
                    if let heureDebut = session.heureDebut {
                        DetailRow(icon: "clock", title: "Heure de début", value: heureDebut)
                    }
                    
                    if let heureFin = session.heureFin {
                        DetailRow(icon: "clock", title: "Heure de fin", value: heureFin)
                    }
                    
                    // Formateur
                    if let formateurName = formateurName {
                        DetailRow(icon: "person.fill", title: "Formateur", value: formateurName)
                    } else if let formateurId = session.formateurId {
                        DetailRow(icon: "person.fill", title: "Formateur", value: "ID \(formateurId)")
                    }
                    
                    // Présentiel/Distanciel
                    if let presentielDistanciel = session.presentielDistancielDisplay {
                        HStack(alignment: .top, spacing: 12) {
                            Text(session.presentielEmoji)
                                .font(.title3)
                                .frame(width: 20)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mode")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(presentielDistanciel)
                                    .font(.body)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    if let nbParticipants = session.nbParticipants {
                        DetailRow(icon: "person.2", title: "Participants", value: "\(nbParticipants)")
                    }
                    
                    if let prix = session.prix {
                        DetailRow(icon: "eurosign.circle", title: "Prix", value: String(format: "%.2f €", prix))
                    }
                    
                    if let notes = session.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.accentColor)
                                Text("Notes")
                                    .font(.headline)
                            }
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("\(AppEmojis.sessions) Session")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Charger les noms de l'école, du client et du formateur si disponibles
            if let ecoleId = session.ecoleId {
                do {
                    let ecole = try await APIService.shared.getEcole(id: ecoleId)
                    ecoleName = ecole.nom
                } catch {
                    // Ignore error, will show ID instead
                }
            }
            if let clientId = session.clientId {
                do {
                    let client = try await APIService.shared.getClient(id: clientId)
                    clientName = client.nom
                } catch {
                    // Ignore error, will show ID instead
                }
            }
            if let formateurId = session.formateurId {
                do {
                    let formateur = try await APIService.shared.getFormateur(id: formateurId)
                    formateurName = formateur.fullName
                } catch {
                    // Ignore error, will show ID instead
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEdit = true
                    }) {
                        Label("Modifier", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        // Copier dans le presse-papier (SHARE-05)
                        ClipboardManager.shared.copyToClipboard(sessionShareText())
                        showingCopyConfirmation = true
                    }) {
                        Label("Copier", systemImage: "doc.on.doc")
                    }
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Label("Partager", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            SessionFormView(viewModel: viewModel, session: session)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [sessionShareText()])
        }
        .alert("Copié !", isPresented: $showingCopyConfirmation) {
            Button("OK") { }
        } message: {
            Text("Les informations de la session ont été copiées dans le presse-papier")
        }
        .alert("Delete Session", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteSession(id: session.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete this session? This action cannot be undone.")
        }
    }
    
    private func sessionShareText() -> String {
        var text = "📅 \(session.titre)\n\n"
        
        // Date
        text += "📆 Date: \(session.formattedDateDebut)"
        if session.formattedDateDebut != session.formattedDateFin {
            text += " - \(session.formattedDateFin)"
        }
        text += "\n"
        
        // Heures si disponibles
        if let heureDebut = session.heureDebut, let heureFin = session.heureFin {
            text += "🕐 Heures: \(heureDebut) - \(heureFin)\n"
        }
        
        // Lieu (nom de l'école si disponible)
        if let ecoleName = ecoleName {
            text += "📍 Lieu: \(ecoleName)\n"
        } else if let ecoleId = session.ecoleId {
            text += "📍 Lieu: École ID \(ecoleId)\n"
        } else {
            text += "📍 Lieu: À définir\n"
        }
        
        // Tarifs
        if let prix = session.prix {
            text += "💰 Tarif: \(String(format: "%.2f €", prix))\n"
        } else {
            text += "💰 Tarif: Non défini\n"
        }
        
        return text
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
            }
            
            Spacer()
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationView {
        SessionDetailView(
            session: Session(
                id: 1,
                titre: "iOS Development",
                description: "Formation iOS avancée",
                dateDebut: "2025-12-04",
                dateFin: "2025-12-04",
                heureDebut: "10:00:00",
                heureFin: "18:00:00",
                clientId: nil,
                ecoleId: nil,
                formateurId: nil,
                nbParticipants: 10,
                statut: "planifié",
                prix: 500.0,
                notes: "Session importante",
                presentielDistanciel: "P"
            ),
            viewModel: SessionsViewModel()
        )
    }
}

