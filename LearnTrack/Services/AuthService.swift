//
//  AuthService.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import Supabase

/// Service for handling authentication operations
class AuthService {
    static let shared = AuthService()
    
    private let supabase = SupabaseService.shared.client
    private let keychain = KeychainService.shared
    
    private init() {}
    
    /// Sign up with email and password
    func signUp(email: String, password: String) async throws {
        let response = try await supabase.auth.signUp(email: email, password: password)
        
        // Save tokens to keychain if session is available (only if email confirmation is disabled)
        // If email confirmation is enabled, session will be nil until user confirms
        if let session = response.session {
            _ = keychain.saveToken(session.accessToken, forKey: Constants.keychainTokenKey)
            _ = keychain.saveToken(session.refreshToken, forKey: Constants.keychainRefreshTokenKey)
        }
    }
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        let session = try await supabase.auth.signIn(email: email, password: password)
        
        // Save tokens to keychain
        _ = keychain.saveToken(session.accessToken, forKey: Constants.keychainTokenKey)
        _ = keychain.saveToken(session.refreshToken, forKey: Constants.keychainRefreshTokenKey)
    }
    
    /// Sign out and clear session
    func signOut() async throws {
        try await supabase.auth.signOut()
        keychain.deleteAllTokens()
    }
    
    /// Get current authenticated user
    func getCurrentUser() async throws -> User? {
        do {
            // Try to get the current session
            let session = try await supabase.auth.session
            
            // Get user from session
            let authUser = session.user
            
            // Try to get user role from user metadata or a separate users table
            // For now, default to "user" role
            // Note: userMetadata["role"] returns AnyJSON?, so we'll use default for now
            // Can be enhanced later to properly extract from metadata
            let role = "user"
            
            return User(
                id: authUser.id,
                email: authUser.email ?? "",
                role: role
            )
        } catch {
            // User not authenticated or session expired
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
    
    /// Refresh the current session
    func refreshSession() async throws {
        guard let storedRefreshToken = keychain.getToken(forKey: Constants.keychainRefreshTokenKey) else {
            return
        }
        
        let session = try await supabase.auth.refreshSession(refreshToken: storedRefreshToken)
        
        // Update tokens in keychain
        _ = keychain.saveToken(session.accessToken, forKey: Constants.keychainTokenKey)
        _ = keychain.saveToken(session.refreshToken, forKey: Constants.keychainRefreshTokenKey)
    }
    
    /// Restore session from keychain on app launch
    func restoreSession() async throws {
        if keychain.getToken(forKey: Constants.keychainRefreshTokenKey) != nil {
            try await refreshSession()
        }
    }
}
