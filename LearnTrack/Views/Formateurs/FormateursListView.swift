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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                
                // Filter Buttons
                FilterButtonsView(viewModel: viewModel)
                
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
                await viewModel.fetchFormateurs()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
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
            // Type Badge
            Circle()
                .fill(formateur.isInterne ? Color.blue : Color.orange)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(formateur.fullName)
                    .font(.headline)
                
                if let email = formateur.email {
                    Text(email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let telephone = formateur.telephone {
                    Text(telephone)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(formateur.type.capitalized)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(formateur.isInterne ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                .foregroundColor(formateur.isInterne ? .blue : .orange)
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Filter Buttons View
struct FilterButtonsView: View {
    @ObservedObject var viewModel: FormateursViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(
                    title: "All",
                    isSelected: viewModel.filterType == nil,
                    action: { viewModel.filterType = nil }
                )
                
                FilterButton(
                    title: "Interne",
                    isSelected: viewModel.filterType == .interne,
                    action: { viewModel.filterType = .interne }
                )
                
                FilterButton(
                    title: "Externe",
                    isSelected: viewModel.filterType == .externe,
                    action: { viewModel.filterType = .externe }
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
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

