//
//  ClientsViewModel.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class ClientsViewModel: ObservableObject {
    @Published var clients: [Client] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let supabase = SupabaseService.shared.client
    
    var filteredClients: [Client] {
        var result = clients
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { client in
                client.fullName.localizedCaseInsensitiveContains(searchText) ||
                client.nom.localizedCaseInsensitiveContains(searchText) ||
                client.prenom.localizedCaseInsensitiveContains(searchText) ||
                (client.email?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (client.entreprise?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Sort alphabetically by name
        return result.sorted { $0.fullName < $1.fullName }
    }
    
    /// Fetch all clients from Supabase
    func fetchClients() async {
        isLoading = true
        errorMessage = nil
        
        #if DEBUG
        print("🔍 Attempting to fetch clients from Supabase...")
        #endif
        
        do {
            let response: [Client] = try await supabase
                .from("clients")
                .select()
                .execute()
                .value
            
            #if DEBUG
            print("✅ Successfully fetched \(response.count) clients")
            #endif
            
            self.clients = response
        } catch {
            let errorDescription = error.localizedDescription
            
            #if DEBUG
            print("❌ Error fetching clients: \(error)")
            print("   Error description: \(errorDescription)")
            #endif
            
            // Check if it's a table not found error
            if errorDescription.contains("relation") || 
               errorDescription.contains("does not exist") ||
               errorDescription.contains("permission denied") ||
               errorDescription.contains("42P01") {
                self.errorMessage = "❌ Table 'clients' not found!\n\nPlease create it in Supabase:\n1. Go to SQL Editor\n2. Run the script from COMPLETE_DATABASE_SETUP.md"
            } else if errorDescription.contains("couldn't be read") || 
                      errorDescription.contains("correct format") ||
                      errorDescription.contains("decoding") {
                self.clients = []
                print("⚠️ Warning: Could not decode clients. Table might be empty or have wrong structure.")
                self.errorMessage = "Table structure mismatch. Check column names match the model."
            } else {
                self.errorMessage = "Failed to load clients: \(errorDescription)\n\nCheck:\n- Internet connection\n- Supabase project is active\n- Tables exist in database"
            }
        }
        
        isLoading = false
    }
    
    /// Create a new client
    func createClient(_ client: Client) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: Client = try await supabase
                .from("clients")
                .insert(client)
                .select()
                .single()
                .execute()
                .value
            
            // Refresh the list
            await fetchClients()
        } catch {
            self.errorMessage = "Failed to create client: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Update an existing client
    func updateClient(_ client: Client) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: Client = try await supabase
                .from("clients")
                .update(client)
                .eq("id", value: client.id)
                .select()
                .single()
                .execute()
                .value
            
            // Refresh the list
            await fetchClients()
        } catch {
            self.errorMessage = "Failed to update client: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Delete a client
    func deleteClient(_ client: Client) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase
                .from("clients")
                .delete()
                .eq("id", value: client.id)
                .execute()
            
            // Refresh the list
            await fetchClients()
        } catch {
            self.errorMessage = "Failed to delete client: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Clear search
    func clearSearch() {
        searchText = ""
    }
}

