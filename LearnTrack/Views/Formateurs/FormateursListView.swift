//
//  FormateursListView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import SwiftUI

struct FormateursListView: View {
    @StateObject private var viewModel = FormateursViewModel()
    @State private var showingAddFormateur = false
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                // Formateurs List
                if viewModel.isLoading && viewModel.formateurs.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredFormateurs.isEmpty {
                    EmptyFormateursView()
                } else {
                    List {
                        ForEach(viewModel.filteredFormateurs) { formateur in
                            NavigationLink(destination: FormateurDetailView(formateur: formateur, viewModel: viewModel)) {
                                FormateurRowView(formateur: formateur)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.fetchFormateurs()
                    }
                }
            }
            .navigationTitle("Formateurs")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFormateur = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFormateur) {
                FormateurFormView(viewModel: viewModel, formateur: nil)
            }
            .task {
                // Fetch formateurs
                await viewModel.fetchFormateurs()
            }
            .onChange(of: viewModel.errorMessage) { oldValue, newValue in
                if newValue != nil && !showingError {
                    // Add small delay to prevent presentation conflicts
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

// MARK: - Formateur Row View
struct FormateurRowView: View {
    let formateur: Formateur
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Badge
            Circle()
                .fill(formateur.actif ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formateur.fullName)
                    .font(.headline)
                
                Text(formateur.email)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let telephone = formateur.telephone {
                    Text(telephone)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let specialites = formateur.specialites, !specialites.isEmpty {
                    Text(specialites.joined(separator: ", "))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if !formateur.actif {
                Text("Inactif")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.2))
                    .foregroundColor(.red)
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty Formateurs View
struct EmptyFormateursView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Formateurs")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to add your first formateur")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    FormateursListView()
}

