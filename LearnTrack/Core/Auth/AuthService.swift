//
//  AuthService.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation

/// Service for handling authentication operations
class AuthService {
    static let shared = AuthService()
    
    private let apiService = APIService.shared
    private let keychain = KeychainManager.shared
    
    private init() {}
    
    /// Sign up with email and password
    func signUp(email: String, password: String, nom: String, prenom: String) async throws -> User? {
        let response = try await apiService.register(email: email, password: password, nom: nom, prenom: prenom)
        
        if response.success, let user = response.user {
            // Save user info to keychain if needed
            return user
        }
        
        throw APIError.badRequest
    }
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws -> User? {
        let response = try await apiService.login(email: email, password: password)
        
        if response.success, let user = response.user {
            // Save user info to keychain if needed
            // Store user ID as token
            _ = keychain.saveToken("\(user.id)", forKey: "user_id")
            return user
        }
        
        throw APIError.badRequest
    }
    
    /// Sign out and clear session
    func signOut() async throws {
        keychain.deleteAllTokens()
    }
    
    /// Get current authenticated user
    func getCurrentUser() async throws -> User? {
        // Check if we have a stored user ID
        guard let userIdString = keychain.getToken(forKey: "user_id"),
              let userId = Int(userIdString) else {
            return nil
        }
        
        // Try to fetch user from API
        do {
            let users = try await apiService.getUsers()
            return users.first { $0.id == userId }
        } catch {
            return nil
        }
    }
    
    /// Check if user is currently authenticated
    func isAuthenticated() async -> Bool {
        do {
            let user = try await getCurrentUser()
            return user != nil
        } catch {
            return false
        }
    }
}

