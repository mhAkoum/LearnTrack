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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(session.isPresentiel ? Color.green : Color.blue)
                            .frame(width: 16, height: 16)
                        
                        Text(session.presentiel_distanciel)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    Text(session.module)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let statut = session.statut {
                        Text(statut)
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.2))
                            .foregroundColor(.accentColor)
                            .cornerRadius(8)
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
                    
                    if let prix = session.prix {
                        DetailRow(icon: "eurosign.circle", title: "Prix", value: String(format: "%.2f €", prix))
                    }
                    
                    if let nda = session.nda, !nda.isEmpty {
                        DetailRow(icon: "doc.text", title: "NDA", value: nda)
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
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEdit = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
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
        .alert("Delete Session", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteSession(session)
                }
            }
        } message: {
            Text("Are you sure you want to delete this session? This action cannot be undone.")
        }
    }
    
    private func sessionShareText() -> String {
        var text = "Session: \(session.module)\n"
        text += "Date: \(session.formattedDateDebut) - \(session.formattedDateFin)\n"
        text += "Type: \(session.presentiel_distanciel)\n"
        if let prix = session.prix {
            text += "Prix: \(String(format: "%.2f €", prix))\n"
        }
        if let notes = session.notes {
            text += "Notes: \(notes)"
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
                date_debut: "2025-12-04T10:00:00",
                date_fin: "2025-12-04T18:00:00",
                module: "iOS Development",
                presentiel_distanciel: "Présentiel"
            ),
            viewModel: SessionsViewModel()
        )
    }
}

