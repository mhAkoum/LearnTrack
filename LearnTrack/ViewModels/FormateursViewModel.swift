//
//  FormateursViewModel.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class FormateursViewModel: ObservableObject {
    @Published var formateurs: [Formateur] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var filterType: Constants.FormateurType?
    
    private let supabase = SupabaseService.shared.client
    
    var filteredFormateurs: [Formateur] {
        var result = formateurs
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { formateur in
                formateur.fullName.localizedCaseInsensitiveContains(searchText) ||
                formateur.nom.localizedCaseInsensitiveContains(searchText) ||
                formateur.prenom.localizedCaseInsensitiveContains(searchText) ||
                (formateur.email?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Apply type filter
        if let filterType = filterType {
            result = result.filter { formateur in
                formateur.type == filterType.rawValue
            }
        }
        
        // Sort alphabetically by name
        return result.sorted { $0.fullName < $1.fullName }
    }
    
    /// Fetch all formateurs from Supabase
    func fetchFormateurs() async {
        isLoading = true
        errorMessage = nil
        
        #if DEBUG
        print("🔍 Attempting to fetch formateurs from Supabase...")
        #endif
        
        do {
            // First, try to get raw JSON to see the structure
            let rawResponse: [AnyJSON] = try await supabase
                .from("formateurs")
                .select()
                .execute()
                .value
            
            #if DEBUG
            if let firstItem = rawResponse.first {
                print("📋 Sample data structure:")
                print("   First item: \(firstItem)")
                if let dict = firstItem.objectValue {
                    print("   ID type: \(type(of: dict["id"]))")
                    print("   ID value: \(dict["id"] ?? "nil")")
                }
            }
            #endif
            
            // Now decode to Formateur
            let response: [Formateur] = try await supabase
                .from("formateurs")
                .select()
                .execute()
                .value
            
            #if DEBUG
            print("✅ Successfully fetched \(response.count) formateurs")
            #endif
            
            self.formateurs = response
        } catch {
            let errorDescription = error.localizedDescription
            
            #if DEBUG
            print("❌ Error fetching formateurs: \(error)")
            print("   Error description: \(errorDescription)")
            #endif
            
            // Check if it's a table not found error
            if errorDescription.contains("relation") || 
               errorDescription.contains("does not exist") ||
               errorDescription.contains("permission denied") ||
               errorDescription.contains("42P01") { // PostgreSQL error code for table not found
                self.errorMessage = "❌ Table 'formateurs' not found!\n\nPlease create it in Supabase:\n1. Go to SQL Editor\n2. Run the script from COMPLETE_DATABASE_SETUP.md"
            } else if errorDescription.contains("couldn't be read") || 
                      errorDescription.contains("correct format") ||
                      errorDescription.contains("decoding") {
                // This usually means the table exists but is empty or has wrong structure
                // Try to continue with empty array
                self.formateurs = []
                print("⚠️ Warning: Could not decode formateurs. Table might be empty or have wrong structure.")
                self.errorMessage = "Table structure mismatch. Check column names match the model."
            } else {
                self.errorMessage = "Failed to load formateurs: \(errorDescription)\n\nCheck:\n- Internet connection\n- Supabase project is active\n- Tables exist in database"
            }
        }
        
        isLoading = false
    }
    
    /// Create a new formateur
    func createFormateur(_ formateur: Formateur) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: Formateur = try await supabase
                .from("formateurs")
                .insert(formateur)
                .select()
                .single()
                .execute()
                .value
            
            // Refresh the list
            await fetchFormateurs()
        } catch {
            self.errorMessage = "Failed to create formateur: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Update an existing formateur
    func updateFormateur(_ formateur: Formateur) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: Formateur = try await supabase
                .from("formateurs")
                .update(formateur)
                .eq("id", value: formateur.id)
                .select()
                .single()
                .execute()
                .value
            
            // Refresh the list
            await fetchFormateurs()
        } catch {
            self.errorMessage = "Failed to update formateur: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Delete a formateur (admin only - check can be added later)
    func deleteFormateur(_ formateur: Formateur) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase
                .from("formateurs")
                .delete()
                .eq("id", value: formateur.id)
                .execute()
            
            // Refresh the list
            await fetchFormateurs()
        } catch {
            self.errorMessage = "Failed to delete formateur: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Clear filters
    func clearFilters() {
        searchText = ""
        filterType = nil
    }
}

