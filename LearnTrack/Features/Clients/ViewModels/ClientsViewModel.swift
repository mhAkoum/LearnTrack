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
    
    private let apiService = APIService.shared
    
    var filteredClients: [Client] {
        var result = clients
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { client in
                client.nom.localizedCaseInsensitiveContains(searchText) ||
                (client.email?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (client.contactNom?.localizedCaseInsensitiveContains(searchText) ?? false)
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

