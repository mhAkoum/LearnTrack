
import Foundation
import SwiftUI
import Combine

@MainActor
class SessionsViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter: FilterType?
    @Published var selectedStatusFilter: String? = nil
    @Published var selectedModeFilter: String? = nil // "Présentiel" ou "Distanciel"
    
    private let apiService = APIService.shared
    
    enum FilterType {
        case date(Date)
        case formateur(Int)
        case client(Int)
    }
    
    var filteredSessions: [Session] {
        var result = sessions
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter { session in
                session.titre.localizedCaseInsensitiveContains(searchText) ||
                (session.description?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                session.statut.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply status filter
        if let statusFilter = selectedStatusFilter {
            result = result.filter { session in
                session.statut.lowercased() == statusFilter.lowercased() ||
                session.statut.lowercased().contains(statusFilter.lowercased())
            }
        }
        
        // Apply mode filter (présentiel/distanciel)
        if let modeFilter = selectedModeFilter {
            result = result.filter { session in
                if modeFilter.lowercased() == "présentiel" || modeFilter.lowercased() == "presentiel" {
                    return session.isPresentiel
                } else if modeFilter.lowercased() == "distanciel" {
                    return session.isDistanciel
                }
                return true
            }
        }
        
        // Apply selected filter
        if let filter = selectedFilter {
            switch filter {
            case .date(let date):
                result = result.filter { session in
                    guard let sessionDate = session.dateDebutDate else { return false }
                    return Calendar.current.isDate(sessionDate, inSameDayAs: date)
                }
            case .formateur(let formateurId):
                result = result.filter { $0.formateurId == formateurId }
            case .client(let clientId):
                result = result.filter { $0.clientId == clientId }
            }
        }
        
        // Sort by date (most recent first)
        return result.sorted { session1, session2 in
            guard let date1 = session1.dateDebutDate, let date2 = session2.dateDebutDate else {
                return false
            }
            return date1 > date2
        }
    }
    
    /// Fetch all sessions from API
    func fetchSessions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getSessions()
            self.sessions = response
        } catch {
            self.errorMessage = "Échec du chargement des sessions : \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    /// Create a new session
    func createSession(_ session: SessionCreate) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await apiService.createSession(session)
            // Refresh the list
            await fetchSessions()
        } catch {
            self.errorMessage = "Échec de la création de la session : \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Update an existing session
    func updateSession(id: Int, _ session: SessionUpdate) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let _ = try await apiService.updateSession(id: id, session)
            // Refresh the list
            await fetchSessions()
        } catch {
            self.errorMessage = "Échec de la mise à jour de la session : \(error.localizedDescription)"
            throw error
        }
        
        isLoading = false
    }
    
    /// Delete a session
    func deleteSession(id: Int) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteSession(id: id)
            // Refresh the list
            await fetchSessions()
        } catch {
            self.errorMessage = "Échec de la suppression de la session : \(error.localizedDescription)"
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

