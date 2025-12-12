
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
            return user
        }
        
        throw APIError.badRequest
    }
    
    /// Sign in with email and password
    func signIn(email: String, password: String) async throws -> User? {
        let response = try await apiService.login(email: email, password: password)
        
        if response.success, let user = response.user {
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
        guard let userIdString = keychain.getToken(forKey: "user_id"),
              let userId = Int(userIdString) else {
            return nil
        }
        
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

