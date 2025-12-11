//
//  FormateurDetailView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct FormateurDetailView: View {
    let formateur: Formateur
    @ObservedObject var viewModel: FormateursViewModel
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    Text(formateur.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if !formateur.actif {
                        Text("Inactif")
                            .font(.subheadline)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Contact Actions
                if formateur.telephone != nil {
                    VStack(spacing: 12) {
                        if let telephone = formateur.telephone {
                            ContactActionButton(
                                icon: "phone.fill",
                                title: "Call",
                                color: .green,
                                action: {
                                    if let url = URL(string: "tel://\(telephone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: ""))") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                            
                            ContactActionButton(
                                icon: "message.fill",
                                title: "SMS",
                                color: .blue,
                                action: {
                                    if let url = URL(string: "sms://\(telephone.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: ""))") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        }
                        
                        ContactActionButton(
                            icon: "envelope.fill",
                            title: "Email",
                            color: .blue,
                            action: {
                                if let url = URL(string: "mailto:\(formateur.email)") {
                                    UIApplication.shared.open(url)
                                }
                            }
                        )
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                // Details Section
                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(icon: "envelope", title: "Email", value: formateur.email)
                    
                    if let telephone = formateur.telephone {
                        DetailRow(icon: "phone", title: "Téléphone", value: telephone)
                    }
                    
                    if let tarifJournalier = formateur.tarifJournalier {
                        DetailRow(icon: "eurosign.circle", title: "Tarif Journalier", value: String(format: "%.2f €", tarifJournalier))
                    }
                    
                    if let adresse = formateur.adresse {
                        DetailRow(icon: "mappin", title: "Adresse", value: adresse)
                    }
                    
                    if let ville = formateur.ville {
                        DetailRow(icon: "mappin", title: "Ville", value: ville)
                    }
                    
                    if let codePostal = formateur.codePostal {
                        DetailRow(icon: "number", title: "Code Postal", value: codePostal)
                    }
                    
                    if let specialites = formateur.specialites, !specialites.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.accentColor)
                                Text("Spécialités")
                                    .font(.headline)
                            }
                            Text(specialites.joined(separator: ", "))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let notes = formateur.notes, !notes.isEmpty {
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
        .navigationTitle("Formateur")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEdit = true
                    }) {
                        Label("Edit", systemImage: "pencil")
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
            FormateurFormView(viewModel: viewModel, formateur: formateur)
        }
        .alert("Delete Formateur", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteFormateur(id: formateur.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete this formateur? This action cannot be undone.")
        }
    }
}

// MARK: - Contact Action Button
struct ContactActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(10)
        }
    }
}

#Preview {
    NavigationView {
        FormateurDetailView(
            formateur: Formateur(
                id: 1,
                nom: "Doe",
                prenom: "John",
                email: "john@example.com",
                telephone: "+33123456789",
                specialites: ["iOS", "Swift"],
                tarifJournalier: 500.0,
                adresse: "123 Main St",
                ville: "Paris",
                codePostal: "75001",
                notes: "Expert iOS",
                actif: true
            ),
            viewModel: FormateursViewModel()
        )
    }
}

