//
//  SessionsViewModel.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import SwiftUI
import Combine
import Supabase

@MainActor
class SessionsViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter: FilterType?
    
    private let supabase = SupabaseService.shared.client
    
    enum FilterType {
        case date(Date)
        case formateur(UUID)
        case client(UUID)
    }
    
    var filteredSessions: [Session] {
        var result = sessions
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { session in
                session.module.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply selected filter
        if let filter = selectedFilter {
            switch filter {
            case .date(let date):
                result = result.filter { session in
                    guard let sessionDate = session.dateDebut else { return false }
                    return Calendar.current.isDate(sessionDate, inSameDayAs: date)
                }
            case .formateur(let formateurId):
                result = result.filter { $0.formateur_id == formateurId }
            case .client(let clientId):
                result = result.filter { $0.client_id == clientId }
            }
        }
        
        // Sort by date (most recent first)
        return result.sorted { session1, session2 in
            guard let date1 = session1.dateDebut, let date2 = session2.dateDebut else {
                return false
            }
            return date1 > date2
        }
    }
    
    /// Fetch all sessions from Supabase
    func fetchSessions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [Session] = try await supabase
                .from("sessions")
                .select()
                .execute()
                .value
            
            self.sessions = response
        } catch {
            self.errorMessage = "Failed to load sessions: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Create a new session
    func createSession(_ session: Session) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: Session = try await supabase
                .from("sessions")
                .insert(session)
                .select()
                .single()
                .execute()
                .value
            
            // Refresh the list
            await fetchSessions()
        } catch {
            self.errorMessage = "Failed to create session: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Update an existing session
    func updateSession(_ session: Session) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _: Session = try await supabase
                .from("sessions")
                .update(session)
                .eq("id", value: session.id)
                .select()
                .single()
                .execute()
                .value
            
            // Refresh the list
            await fetchSessions()
        } catch {
            self.errorMessage = "Failed to update session: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Delete a session
    func deleteSession(_ session: Session) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await supabase
                .from("sessions")
                .delete()
                .eq("id", value: session.id)
                .execute()
            
            // Refresh the list
            await fetchSessions()
        } catch {
            self.errorMessage = "Failed to delete session: \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Clear search and filters
    func clearFilters() {
        searchText = ""
        selectedFilter = nil
    }
}

