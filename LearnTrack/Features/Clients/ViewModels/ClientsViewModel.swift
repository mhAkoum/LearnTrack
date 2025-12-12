//
//  ClientsViewModel.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter: FilterType?
    
    private let apiService = APIService.shared
    
    enum FilterType: String, CaseIterable {
        case tous = "tous"
        case actifs = "actifs"
        case inactifs = "inactifs"
        case avecContact = "avec_contact"
        
        var title: String {
            switch self {
            case .tous: return "Tous"
            case .actifs: return "Actifs"
            case .inactifs: return "Inactifs"
            case .avecContact: return "Avec contact"
            }
        }
        
        var emoji: String {
            switch self {
            case .tous: return "🔍"
            case .actifs: return "✅"
            case .inactifs: return "❌"
            case .avecContact: return "👤"
            }
        }
    }
    
    var filteredClients: [Client] {
        var result = clients
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { client in
                client.nom.localizedCaseInsensitiveContains(searchText) ||
                (client.email?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (client.contactNom?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (client.ville?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (client.siret?.localizedCaseInsensitiveContains(searchText) ?? false)
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
            case .avecContact:
                result = result.filter { client in
                    client.contactNom != nil && !client.contactNom!.isEmpty
                }
            }
        }
        
        // Sort alphabetically by name
        return result.sorted { $0.nom < $1.nom }
    }
    
    /// Fetch all clients from API
    func fetchClients() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getClients()
            self.clients = response
        } catch {
            self.errorMessage = "Failed to load clients: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Create a new client
    func createClient(_ client: ClientCreate) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await apiService.createClient(client)
            // Refresh the list
            await fetchClients()
        } catch {
            self.errorMessage = "Failed to create client: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Update an existing client
    func updateClient(id: Int, _ client: ClientUpdate) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await apiService.updateClient(id: id, client)
            // Refresh the list
            await fetchClients()
        } catch {
            self.errorMessage = "Failed to update client: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Delete a client
    func deleteClient(id: Int) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteClient(id: id)
            // Refresh the list
            await fetchClients()
        } catch {
            self.errorMessage = "Failed to delete client: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
}

