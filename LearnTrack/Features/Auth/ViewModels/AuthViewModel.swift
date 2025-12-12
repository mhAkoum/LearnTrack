
import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    
    init() {
        Task {
            await checkAuthStatus()
        }
    }
    
    /// Check authentication status on app launch
    func checkAuthStatus() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Get current user
            if let user = try await authService.getCurrentUser() {
                self.currentUser = user
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
                self.currentUser = nil
            }
        } catch {
            // Not authenticated or session expired
            self.isAuthenticated = false
            self.currentUser = nil
        }
        
        isLoading = false
    }
    
    /// Sign in with email and password
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password"
            isLoading = false
            return
        }
        
        guard email.isValidEmail else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        do {
            if let user = try await authService.signIn(email: email, password: password) {
                self.currentUser = user
                self.isAuthenticated = true
            } else {
                errorMessage = "Invalid email or password"
                isAuthenticated = false
                currentUser = nil
            }
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
            currentUser = nil
        }
        
        isLoading = false
    }
    
    /// Sign up with email and password
    func signUp(email: String, password: String, nom: String, prenom: String) async {
        isLoading = true
        errorMessage = nil
        
        // Validate input
        guard !email.isEmpty, !password.isEmpty, !nom.isEmpty, !prenom.isEmpty else {
            errorMessage = "Please fill in all fields"
            isLoading = false
            return
        }
        
        guard email.isValidEmail else {
            errorMessage = "Please enter a valid email address"
            isLoading = false
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            isLoading = false
            return
        }
        
        do {
            if let user = try await authService.signUp(email: email, password: password, nom: nom, prenom: prenom) {
                self.currentUser = user
                self.isAuthenticated = true
            } else {
                errorMessage = "Failed to create account"
            }
        } catch {
            errorMessage = error.localizedDescription
            isAuthenticated = false
            currentUser = nil
        }
        
        isLoading = false
    }
    
    /// Sign out
    func logout() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Clear error message
    func clearError() {
        errorMessage = nil
    }
}

