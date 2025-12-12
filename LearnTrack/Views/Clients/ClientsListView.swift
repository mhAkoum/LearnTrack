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
                SearchBar(text: $viewModel.searchText, placeholder: "Rechercher des clients...")
                    .padding(.horizontal)
                
                // Filter View
                FilterView(
                    selectedFilter: Binding(
                        get: {
                            if let filter = viewModel.selectedFilter {
                                return FilterOption(id: filter.rawValue, title: filter.title, emoji: filter.emoji)
                            }
                            return nil
                        },
                        set: { newValue in
                            if let newValue = newValue, let filterType = ClientsViewModel.FilterType(rawValue: newValue.id) {
                                viewModel.selectedFilter = filterType
                            } else {
                                viewModel.selectedFilter = nil
                            }
                        }
                    ),
                    filters: ClientsViewModel.FilterType.allCases.filter { $0 != .tous }.map {
                        FilterOption(id: $0.rawValue, title: $0.title, emoji: $0.emoji)
                    },
                    color: AppColors.clients
                )
                
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
            .navigationTitle("\(AppEmojis.clients) Clients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddClient = true
                    }) {
                        Label("Ajouter", systemImage: "plus.circle.fill")
                            .foregroundColor(AppColors.clients)
                            .font(.title3)
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
            // Avatar/Icon Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: client.actif ? 
                                [AppColors.clients.opacity(0.3), AppColors.clients.opacity(0.1)] :
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Text(client.actif ? "👥" : "😴")
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(client.nom)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if client.actif {
                        Text(AppEmojis.star)
                            .font(.caption)
                    }
                }
                
                if let ville = client.ville {
                    HStack(spacing: 4) {
                        Text(AppEmojis.location)
                            .font(.caption2)
                        Text(ville)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                if let email = client.email {
                    HStack(spacing: 4) {
                        Text(AppEmojis.email)
                            .font(.caption2)
                        Text(email)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if !client.actif {
                Text("Inactif")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.error.opacity(0.2))
                    .foregroundColor(AppColors.error)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

// MARK: - Empty Clients View
struct EmptyClientsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("👥")
                .font(.system(size: 80))
            
            Text("Aucun client")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.clients)
            
            Text("Appuyez sur \(AppEmojis.add) pour ajouter un nouveau client")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ClientsListView()
}
