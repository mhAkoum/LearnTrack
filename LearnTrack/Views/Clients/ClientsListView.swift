//
//  ClientsListView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct ClientsListView: View {
    @StateObject private var viewModel = ClientsViewModel()
    @State private var showingAddClient = false
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                // Clients List
                if viewModel.isLoading && viewModel.clients.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredClients.isEmpty {
                    EmptyClientsView()
                } else {
                    List {
                        ForEach(viewModel.filteredClients) { client in
                            NavigationLink(destination: ClientDetailView(client: client, viewModel: viewModel)) {
                                ClientRowView(client: client)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.fetchClients()
                    }
                }
            }
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddClient = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                ClientFormView(viewModel: viewModel, client: nil)
            }
            .task {
                await viewModel.fetchClients()
            }
            .onChange(of: viewModel.errorMessage) { oldValue, newValue in
                if newValue != nil && !showingError {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingError = true
                    }
                } else if newValue == nil {
                    showingError = false
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") {
                    viewModel.errorMessage = nil
                    showingError = false
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - Client Row View
struct ClientRowView: View {
    let client: Client
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar/Icon
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(client.nom.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundColor(.green)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(client.nom)
                    .font(.headline)
                
                if let ville = client.ville {
                    Text(ville)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let email = client.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty Clients View
struct EmptyClientsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Clients")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to add a new client")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ClientsListView()
}
