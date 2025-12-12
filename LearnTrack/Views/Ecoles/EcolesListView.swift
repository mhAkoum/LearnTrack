
import SwiftUI

struct EcolesListView: View {
    @StateObject private var viewModel = EcolesViewModel()
    @State private var showingAddEcole = false
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(text: $viewModel.searchText, placeholder: "Rechercher des écoles...")
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
                        Label("Ajouter", systemImage: "plus.circle.fill")
                            .foregroundColor(AppColors.ecoles)
                            .font(.title3)
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

// MARK: - Ecole Row View
struct EcoleRowView: View {
    let ecole: Ecole
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: ecole.actif ? 
                                [AppColors.ecoles.opacity(0.3), AppColors.ecoles.opacity(0.1)] :
                                [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: ecole.actif ? AppIcons.ecoles : "graduationcap.circle.badge.xmark")
                    .font(.title2)
                    .foregroundColor(ecole.actif ? AppColors.ecoles : .gray)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(ecole.nom)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if ecole.actif {
                        Image(systemName: AppIcons.star)
                            .font(.caption)
                            .foregroundColor(AppColors.ecoles)
                    }
                }
                
                if let responsableNom = ecole.responsableNom {
                    HStack(spacing: 4) {
                        Image(systemName: AppIcons.person)
                            .font(.caption2)
                        Text(responsableNom)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                if let email = ecole.email {
                    HStack(spacing: 4) {
                        Image(systemName: AppIcons.email)
                            .font(.caption2)
                        Text(email)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                if let capacite = ecole.capacite {
                    HStack(spacing: 4) {
                        Image(systemName: AppIcons.participants)
                            .font(.caption2)
                        Text("Capacité: \(capacite)")
                            .font(.caption)
                    }
                    .foregroundColor(AppColors.ecoles)
                }
            }
            
            Spacer()
            
            if !ecole.actif {
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

// MARK: - Empty Ecoles View
struct EmptyEcolesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: AppIcons.ecoles)
                .font(.system(size: 60))
                .foregroundColor(AppColors.ecoles.opacity(0.5))
            
            Text("Aucune école")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.ecoles)
            
            Text("Appuyez sur le bouton + pour ajouter une nouvelle école")
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
    EcolesListView()
}
