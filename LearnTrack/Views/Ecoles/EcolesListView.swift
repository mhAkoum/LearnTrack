//
//  EcolesListView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct EcolesListView: View {
    @StateObject private var viewModel = EcolesViewModel()
    @State private var showingAddEcole = false
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                // Ecoles List
                if viewModel.isLoading && viewModel.ecoles.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredEcoles.isEmpty {
                    EmptyEcolesView()
                } else {
                    List {
                        ForEach(viewModel.filteredEcoles) { ecole in
                            NavigationLink(destination: EcoleDetailView(ecole: ecole, viewModel: viewModel)) {
                                EcoleRowView(ecole: ecole)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.fetchEcoles()
                    }
                }
            }
            .navigationTitle("Écoles")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddEcole = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEcole) {
                EcoleFormView(viewModel: viewModel, ecole: nil)
            }
            .task {
                await viewModel.fetchEcoles()
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

// MARK: - Ecole Row View
struct EcoleRowView: View {
    let ecole: Ecole
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Circle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.purple)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(ecole.nom)
                    .font(.headline)
                
                if let contactNom = ecole.contact_nom {
                    Text(contactNom)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let contactEmail = ecole.contact_email {
                    Text(contactEmail)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty Ecoles View
struct EmptyEcolesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Écoles")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to add a new école")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    EcolesListView()
}
