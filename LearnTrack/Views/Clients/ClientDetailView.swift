//
//  ClientDetailView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct ClientDetailView: View {
    let client: Client
    @ObservedObject var viewModel: ClientsViewModel
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 50, height: 50)
                            .overlay(
                                Text(String(client.prenom.prefix(1)).uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(client.fullName)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let entreprise = client.entreprise {
                                Text(entreprise)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Contact Actions
                if client.telephone != nil || client.email != nil {
                    VStack(spacing: 12) {
                        if let telephone = client.telephone {
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
                        
                        if let email = client.email {
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
                        
                        // Open address in Maps (if available)
                        if let adresse = client.adresse, !adresse.isEmpty {
                            ContactActionButton(
                                icon: "map.fill",
                                title: "Open in Maps",
                                color: .red,
                                action: {
                                    openAddressInMaps(adresse)
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
                    if let email = client.email {
                        DetailRow(icon: "envelope", title: "Email", value: email)
                    }
                    
                    if let telephone = client.telephone {
                        DetailRow(icon: "phone", title: "Téléphone", value: telephone)
                    }
                    
                    if let entreprise = client.entreprise {
                        DetailRow(icon: "building.2", title: "Entreprise", value: entreprise)
                    }
                    
                    if let adresse = client.adresse {
                        DetailRow(icon: "mappin", title: "Adresse", value: adresse)
                    }
                    
                    if let notes = client.notes, !notes.isEmpty {
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
        .navigationTitle("Client")
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
            ClientFormView(viewModel: viewModel, client: client)
        }
        .alert("Delete Client", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteClient(client)
                }
            }
        } message: {
            Text("Are you sure you want to delete this client? This action cannot be undone.")
        }
    }
    
    private func openAddressInMaps(_ address: String) {
        // Use Maps URL scheme to open address
        if let encodedAddress = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: "http://maps.apple.com/?q=\(encodedAddress)") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationView {
        ClientDetailView(
            client: Client(
                nom: "Doe",
                prenom: "John",
                email: "john@example.com",
                telephone: "+33123456789",
                entreprise: "TechCorp",
                adresse: "123 Main St, Paris"
            ),
            viewModel: ClientsViewModel()
        )
    }
}
