
import Foundation
import SwiftUI
import Combine

@MainActor
class FormateursViewModel: ObservableObject {
    @Published var formateurs: [Formateur] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter: FilterType?
    
    private let apiService = APIService.shared
    
    enum FilterType: String, CaseIterable {
        case tous = "tous"
        case actifs = "actifs"
        case inactifs = "inactifs"
        case avecSpecialites = "avec_specialites"
        
        var title: String {
            switch self {
            case .tous: return "Tous"
            case .actifs: return "Actifs"
            case .inactifs: return "Inactifs"
            case .avecSpecialites: return "Avec spécialités"
            }
        }
        
        var icon: String {
            switch self {
            case .tous: return AppIcons.search
            case .actifs: return AppIcons.success
            case .inactifs: return AppIcons.error
            case .avecSpecialites: return AppIcons.star
            }
        }
    }
    
    var filteredFormateurs: [Formateur] {
        var result = formateurs
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { formateur in
                formateur.fullName.localizedCaseInsensitiveContains(searchText) ||
                formateur.nom.localizedCaseInsensitiveContains(searchText) ||
                formateur.prenom.localizedCaseInsensitiveContains(searchText) ||
                formateur.email.localizedCaseInsensitiveContains(searchText) ||
                (formateur.specialites?.joined(separator: " ").localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply selected filter
        if let filter = selectedFilter {
            switch filter {
            case .tous:
                break
            case .actifs:
                result = result.filter { $0.actif }
            case .inactifs:
                result = result.filter { !$0.actif }
            case .avecSpecialites:
                result = result.filter { formateur in
                    guard let specialites = formateur.specialites else { return false }
                    return !specialites.isEmpty
                }
            }
        }
        
        // Sort alphabetically by name
        return result.sorted { $0.fullName < $1.fullName }
    }
    
    /// Fetch all formateurs from API
    func fetchFormateurs() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getFormateurs()
            self.formateurs = response
        } catch {
            self.errorMessage = "Échec du chargement des formateurs : \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Create a new formateur
    func createFormateur(_ formateur: FormateurCreate) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await apiService.createFormateur(formateur)
            // Refresh the list
            await fetchFormateurs()
        } catch {
            self.errorMessage = "Échec de la création du formateur : \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Update an existing formateur
    func updateFormateur(id: Int, _ formateur: FormateurUpdate) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await apiService.updateFormateur(id: id, formateur)
            // Refresh the list
            await fetchFormateurs()
        } catch {
            self.errorMessage = "Échec de la mise à jour du formateur : \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Delete a formateur
    func deleteFormateur(id: Int) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteFormateur(id: id)
            // Refresh the list
            await fetchFormateurs()
        } catch {
            self.errorMessage = "Échec de la suppression du formateur : \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
}

