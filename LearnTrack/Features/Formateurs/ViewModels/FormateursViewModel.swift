//
//  FormateursViewModel.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class FormateursViewModel: ObservableObject {
    @Published var formateurs: [Formateur] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let apiService = APIService.shared
    
    var filteredFormateurs: [Formateur] {
        var result = formateurs
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { formateur in
                formateur.fullName.localizedCaseInsensitiveContains(searchText) ||
                formateur.nom.localizedCaseInsensitiveContains(searchText) ||
                formateur.prenom.localizedCaseInsensitiveContains(searchText) ||
                formateur.email.localizedCaseInsensitiveContains(searchText)
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
            self.errorMessage = "Failed to load formateurs: \(error.localizedDescription)"
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
            self.errorMessage = "Failed to create formateur: \(error.localizedDescription)"
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
            self.errorMessage = "Failed to update formateur: \(error.localizedDescription)"
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
            self.errorMessage = "Failed to delete formateur: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
}

