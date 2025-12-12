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
    @State private var showingCopyConfirmation = false
    
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
                                Text(String(client.nom.prefix(1)).uppercased())
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(client.nom)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            if let ville = client.ville {
                                Text(ville)
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
                    
                    if let ville = client.ville {
                        DetailRow(icon: "mappin", title: "Ville", value: ville)
                    }
                    
                    if let codePostal = client.codePostal {
                        DetailRow(icon: "number", title: "Code Postal", value: codePostal)
                    }
                    
                    if let siret = client.siret {
                        DetailRow(icon: "building.2", title: "SIRET", value: siret)
                    }
                    
                    if let contactNom = client.contactNom {
                        DetailRow(icon: "person", title: "Contact", value: contactNom)
                    }
                    
                    if let contactEmail = client.contactEmail {
                        DetailRow(icon: "envelope", title: "Email Contact", value: contactEmail)
                    }
                    
                    if let contactTelephone = client.contactTelephone {
                        DetailRow(icon: "phone", title: "Téléphone Contact", value: contactTelephone)
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
                        Label("Modifier", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        // Copier dans le presse-papier (SHARE-05)
                        let text = clientShareText()
                        ClipboardManager.shared.copyToClipboard(text)
                        showingCopyConfirmation = true
                    }) {
                        Label("Copier", systemImage: "doc.on.doc")
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
        .alert("Copié !", isPresented: $showingCopyConfirmation) {
            Button("OK") { }
        } message: {
            Text("Les informations du client ont été copiées dans le presse-papier")
        }
        .sheet(isPresented: $showingEdit) {
            ClientFormView(viewModel: viewModel, client: client)
        }
        .alert("Delete Client", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    try? await viewModel.deleteClient(id: client.id)
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
    
    private func clientShareText() -> String {
        var text = "\(AppEmojis.clients) \(client.nom)\n\n"
        if let email = client.email {
            text += "\(AppEmojis.email) Email: \(email)\n"
        }
        if let telephone = client.telephone {
            text += "\(AppEmojis.phone) Téléphone: \(telephone)\n"
        }
        if let adresse = client.adresse {
            text += "\(AppEmojis.location) Adresse: \(adresse)"
            if let ville = client.ville {
                text += ", \(ville)"
            }
            if let codePostal = client.codePostal {
                text += " \(codePostal)"
            }
            text += "\n"
        }
        if let siret = client.siret {
            text += "🏢 SIRET: \(siret)\n"
        }
        if let contactNom = client.contactNom {
            text += "👤 Contact: \(contactNom)"
            if let contactEmail = client.contactEmail {
                text += " (\(contactEmail))"
            }
            text += "\n"
        }
        return text
    }
}

#Preview {
    NavigationView {
        ClientDetailView(
            client: Client(
                id: 1,
                nom: "TechCorp",
                email: "contact@techcorp.com",
                telephone: "+33123456789",
                adresse: "123 Main St",
                ville: "Paris",
                codePostal: "75001",
                siret: "12345678901234",
                contactNom: "John Doe",
                contactEmail: "john@example.com",
                contactTelephone: "+33123456789",
                notes: "Important client",
                actif: true
            ),
            viewModel: ClientsViewModel()
        )
    }
}
