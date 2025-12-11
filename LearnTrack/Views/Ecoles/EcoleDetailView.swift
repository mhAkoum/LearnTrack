//
//  EcoleDetailView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct EcoleDetailView: View {
    let ecole: Ecole
    @ObservedObject var viewModel: EcolesViewModel
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(.purple)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ecole.nom)
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Contact Actions
                if ecole.telephone != nil || ecole.email != nil {
                    VStack(spacing: 12) {
                        if let telephone = ecole.telephone {
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
                        }
                        
                        if let email = ecole.email {
                            ContactActionButton(
                                icon: "envelope.fill",
                                title: "Email",
                                color: .blue,
                                action: {
                                    if let url = URL(string: "mailto:\(email)") {
                                        UIApplication.shared.open(url)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                
                // Details Section
                VStack(alignment: .leading, spacing: 16) {
                    if let responsableNom = ecole.responsableNom {
                        DetailRow(icon: "person", title: "Responsable", value: responsableNom)
                    }
                    
                    if let email = ecole.email {
                        DetailRow(icon: "envelope", title: "Email", value: email)
                    }
                    
                    if let telephone = ecole.telephone {
                        DetailRow(icon: "phone", title: "Téléphone", value: telephone)
                    }
                    
                    if let adresse = ecole.adresse {
                        DetailRow(icon: "mappin", title: "Adresse", value: adresse)
                    }
                    
                    if let ville = ecole.ville {
                        DetailRow(icon: "mappin", title: "Ville", value: ville)
                    }
                    
                    if let codePostal = ecole.codePostal {
                        DetailRow(icon: "number", title: "Code Postal", value: codePostal)
                    }
                    
                    if let capacite = ecole.capacite {
                        DetailRow(icon: "person.2", title: "Capacité", value: "\(capacite)")
                    }
                    
                    if let notes = ecole.notes, !notes.isEmpty {
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
        .navigationTitle("École")
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
            EcoleFormView(viewModel: viewModel, ecole: ecole)
        }
        .alert("Delete École", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteEcole(id: ecole.id)
                }
            }
        } message: {
            Text("Are you sure you want to delete this école? This action cannot be undone.")
        }
    }
}

#Preview {
    NavigationView {
        EcoleDetailView(
            ecole: Ecole(
                id: 1,
                nom: "EPITA",
                adresse: "14-16 Rue Voltaire",
                ville: "Le Kremlin-Bicêtre",
                codePostal: "94270",
                telephone: "+33123456789",
                email: "contact@epita.fr",
                responsableNom: "John Doe",
                capacite: 100,
                notes: "École d'ingénieurs",
                actif: true
            ),
            viewModel: EcolesViewModel()
        )
    }
}
