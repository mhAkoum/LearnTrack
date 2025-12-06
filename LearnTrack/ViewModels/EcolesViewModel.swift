//
//  EcolesViewModel.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class EcolesViewModel: ObservableObject {
    @Published var ecoles: [Ecole] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    
    private let supabase = SupabaseService.shared.client
    
    var filteredEcoles: [Ecole] {
        var result = ecoles
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { ecole in
                ecole.nom.localizedCaseInsensitiveContains(searchText) ||
                (ecole.contact_nom?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (ecole.contact_email?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Sort alphabetically by name
        return result.sorted { $0.nom < $1.nom }
    }
    
    /// Fetch all ecoles from Supabase
    func fetchEcoles() async {
        isLoading = true
        errorMessage = nil
        
        #if DEBUG
        print("🔍 Attempting to fetch ecoles from Supabase...")
        #endif
        
        do {
            let response: [Ecole] = try await supabase
                .from("ecoles")
                .select()
                .execute()
                .value
            
            #if DEBUG
            print("✅ Successfully fetched \(response.count) ecoles")
            #endif
            
            self.ecoles = response
        } catch {
            let errorDescription = error.localizedDescription
            
            #if DEBUG
            print("❌ Error fetching ecoles: \(error)")
            print("   Error description: \(errorDescription)")
            if let decodingError = error as? DecodingError {
                print("   Decoding error details: \(decodingError)")
            }
            #endif
            
            // Check if it's a table not found error
            if errorDescription.contains("relation") || 
               errorDescription.contains("does not exist") ||
               errorDescription.contains("permission denied") ||
               errorDescription.contains("42P01") {
                self.errorMessage = "❌ Table 'ecoles' not found!\n\nPlease create it in Supabase:\n1. Go to SQL Editor\n2. Run the script from COMPLETE_DATABASE_SETUP.md"
            } else if errorDescription.contains("couldn't be read") || 
                      errorDescription.contains("correct format") ||
                      errorDescription.contains("decoding") ||
                      error is DecodingError {
                self.ecoles = []
                #if DEBUG
                print("⚠️ Warning: Could not decode ecoles. Table might be empty or have wrong structure.")
                if let decodingError = error as? DecodingError {
                    print("   Decoding error: \(decodingError)")
                }
                #endif
                self.errorMessage = "Table structure mismatch. Check column names match the model.\n\nExpected columns:\n- id (uuid)\n- nom (text)\n- contact_nom, contact_email, contact_telephone, adresse, notes (text, nullable)\n- created_at, updated_at (timestamptz, nullable)"
            } else {
                self.errorMessage = "Failed to load ecoles: \(errorDescription)\n\nCheck:\n- Internet connection\n- Supabase project is active\n- Tables exist in database"
            }
        }
        
        isLoading = false
    }
    
    /// Create a new ecole
    func createEcole(_ ecole: Ecole) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: Ecole = try await supabase
                .from("ecoles")
                .insert(ecole)
                .select()
                .single()
                .execute()
                .value
            
            // Refresh the list
            await fetchEcoles()
        } catch {
            self.errorMessage = "Failed to create ecole: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Update an existing ecole
    func updateEcole(_ ecole: Ecole) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: Ecole = try await supabase
                .from("ecoles")
                .update(ecole)
                .eq("id", value: ecole.id)
                .select()
                .single()
                .execute()
                .value
            
            // Refresh the list
            await fetchEcoles()
        } catch {
            self.errorMessage = "Failed to update ecole: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Delete an ecole
    func deleteEcole(_ ecole: Ecole) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase
                .from("ecoles")
                .delete()
                .eq("id", value: ecole.id)
                .execute()
            
            // Refresh the list
            await fetchEcoles()
        } catch {
            self.errorMessage = "Failed to delete ecole: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Clear search
    func clearSearch() {
        searchText = ""
    }
}

