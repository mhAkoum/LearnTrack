//
//  EcolesViewModel.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class EcolesViewModel: ObservableObject {
    @Published var ecoles: [Ecole] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let apiService = APIService.shared
    
    var filteredEcoles: [Ecole] {
        var result = ecoles
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { ecole in
                ecole.nom.localizedCaseInsensitiveContains(searchText) ||
                (ecole.responsableNom?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (ecole.email?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Sort alphabetically by name
        return result.sorted { $0.nom < $1.nom }
    }
    
    /// Fetch all ecoles from API
    func fetchEcoles() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getEcoles()
            self.ecoles = response
        } catch {
            self.errorMessage = "Échec du chargement des écoles : \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Create a new ecole
    func createEcole(_ ecole: EcoleCreate) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await apiService.createEcole(ecole)
            // Refresh the list
            await fetchEcoles()
        } catch {
            self.errorMessage = "Échec de la création de l'école : \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Update an existing ecole
    func updateEcole(id: Int, _ ecole: EcoleUpdate) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await apiService.updateEcole(id: id, ecole)
            // Refresh the list
            await fetchEcoles()
        } catch {
            self.errorMessage = "Échec de la mise à jour de l'école : \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Delete an ecole
    func deleteEcole(id: Int) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteEcole(id: id)
            // Refresh the list
            await fetchEcoles()
        } catch {
            self.errorMessage = "Échec de la suppression de l'école : \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
}

