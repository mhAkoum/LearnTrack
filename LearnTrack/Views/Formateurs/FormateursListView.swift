
import SwiftUI

struct FormateursListView: View {
    @StateObject private var viewModel = FormateursViewModel()
    @State private var showingAddFormateur = false
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText, placeholder: "Rechercher des formateurs...")
                    .padding(.horizontal)
                
                // Filter View
                FilterView(
                    selectedFilter: Binding(
                        get: {
                            if let filter = viewModel.selectedFilter {
                                return FilterOption(id: filter.rawValue, title: filter.title, icon: filter.icon)
                            }
                            return nil
                        },
                        set: { newValue in
                            if let newValue = newValue, let filterType = FormateursViewModel.FilterType(rawValue: newValue.id) {
                                viewModel.selectedFilter = filterType
                            } else {
                                viewModel.selectedFilter = nil
                            }
                        }
                    ),
                    filters: FormateursViewModel.FilterType.allCases.filter { $0 != .tous }.map {
                        FilterOption(id: $0.rawValue, title: $0.title, icon: $0.icon)
                    },
                    color: AppColors.formateurs
                )
                
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
                        Label("Ajouter", systemImage: "plus.circle.fill")
                            .foregroundColor(AppColors.formateurs)
                            .font(.title3)
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
            .alert("Erreur", isPresented: $showingError) {
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
            // Avatar/Icon Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: formateur.actif ? 
                                [AppColors.formateurs.opacity(0.3), AppColors.formateurs.opacity(0.1)] :
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: formateur.actif ? AppIcons.formateurs : "person.crop.circle.badge.xmark")
                    .font(.title2)
                    .foregroundColor(formateur.actif ? AppColors.formateurs : .gray)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(formateur.fullName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if formateur.actif {
                        Image(systemName: AppIcons.star)
                            .font(.caption)
                            .foregroundColor(AppColors.formateurs)
                    }
                }
                
                HStack(spacing: 8) {
                    Label {
                        Text(formateur.email)
                            .font(.caption)
                    } icon: {
                        Image(systemName: AppIcons.email)
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
                
                if let telephone = formateur.telephone {
                    HStack(spacing: 4) {
                        Image(systemName: AppIcons.phone)
                            .font(.caption2)
                        Text(telephone)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                if let specialites = formateur.specialites, !specialites.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(specialites.prefix(3), id: \.self) { specialite in
                                Text(specialite)
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(AppColors.formateurs.opacity(0.2))
                                    .foregroundColor(AppColors.formateurs)
                                    .cornerRadius(6)
                            }
                            if specialites.count > 3 {
                                Text("+\(specialites.count - 3)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            if !formateur.actif {
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

// MARK: - Empty Formateurs View
struct EmptyFormateursView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: AppIcons.formateurs)
                .font(.system(size: 60))
                .foregroundColor(AppColors.formateurs.opacity(0.5))
            
            Text("Aucun formateur")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.formateurs)
            
            Text("Appuyez sur le bouton + pour ajouter votre premier formateur")
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
    FormateursListView()
}

