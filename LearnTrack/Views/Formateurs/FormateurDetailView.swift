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
                    HStack {
                        Circle()
                            .fill(formateur.isInterne ? Color.blue : Color.orange)
                            .frame(width: 16, height: 16)
                        
                        Text(formateur.type.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    Text(formateur.fullName)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Contact Actions
                if formateur.telephone != nil || formateur.email != nil {
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
                        
                        if let email = formateur.email {
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
                    if let email = formateur.email {
                        DetailRow(icon: "envelope", title: "Email", value: email)
                    }
                    
                    if let telephone = formateur.telephone {
                        DetailRow(icon: "phone", title: "Téléphone", value: telephone)
                    }
                    
                    if let specialites = formateur.specialites, !specialites.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.accentColor)
                                Text("Spécialités")
                                    .font(.headline)
                            }
                            Text(specialites)
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
                    try? await viewModel.deleteFormateur(formateur)
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
                nom: "Doe",
                prenom: "John",
                email: "john@example.com",
                telephone: "+33123456789",
                type: "interne"
            ),
            viewModel: FormateursViewModel()
        )
    }
}

