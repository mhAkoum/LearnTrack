//
//  Phase1Tests.swift
//  LearnTrackTests
//
//  Created on 04/12/2025.
//  Unit tests for Phase 1 setup verification
//

import Testing
@testable import LearnTrack

struct Phase1Tests {
    
    // MARK: - Constants Tests
    
    @Test("Constants: Supabase URL is configured")
    func testSupabaseURL() {
        #expect(!Constants.supabaseURL.isEmpty)
        #expect(Constants.supabaseURL.contains("supabase.co"))
    }
    
    @Test("Constants: Supabase key is configured")
    func testSupabaseKey() {
        #expect(!Constants.supabasePublishableKey.isEmpty)
        #expect(Constants.supabasePublishableKey.starts(with: "sb_publishable_"))
    }
    
    @Test("Constants: Keychain keys are defined")
    func testKeychainKeys() {
        #expect(!Constants.keychainTokenKey.isEmpty)
        #expect(!Constants.keychainRefreshTokenKey.isEmpty)
    }
    
    // MARK: - Model Tests
    
    @Test("User Model: Can be instantiated")
    func testUserModelCreation() {
        let user = User(
            id: UUID(),
            email: "test@example.com",
            role: "admin"
        )
        
        #expect(user.email == "test@example.com")
        #expect(user.role == "admin")
        #expect(user.isAdmin == true)
    }
    
    @Test("User Model: Role detection works")
    func testUserRoleDetection() {
        let admin = User(id: UUID(), email: "admin@test.com", role: "admin")
        let user = User(id: UUID(), email: "user@test.com", role: "user")
        
        #expect(admin.isAdmin == true)
        #expect(user.isAdmin == false)
    }
    
    @Test("Session Model: Can be instantiated")
    func testSessionModelCreation() {
        let session = Session(
            date_debut: "2025-12-04T10:00:00",
            date_fin: "2025-12-04T18:00:00",
            module: "iOS Development",
            presentiel_distanciel: "Présentiel"
        )
        
        #expect(session.module == "iOS Development")
        #expect(session.isPresentiel == true)
        #expect(session.presentiel_distanciel == "Présentiel")
    }
    
    @Test("Session Model: Date parsing works")
    func testSessionDateParsing() {
        let session = Session(
            date_debut: "2025-12-04T10:00:00",
            date_fin: "2025-12-04T18:00:00",
            module: "Test",
            presentiel_distanciel: "Présentiel"
        )
        
        #expect(session.dateDebut != nil)
        #expect(session.dateFin != nil)
    }
    
    @Test("Formateur Model: Can be instantiated")
    func testFormateurModelCreation() {
        let formateur = Formateur(
            nom: "Doe",
            prenom: "John",
            email: "john@example.com",
            type: "interne"
        )
        
        #expect(formateur.nom == "Doe")
        #expect(formateur.prenom == "John")
        #expect(formateur.fullName == "John Doe")
        #expect(formateur.isInterne == true)
    }
    
    @Test("Client Model: Can be instantiated")
    func testClientModelCreation() {
        let client = Client(
            nom: "Smith",
            prenom: "Jane",
            email: "jane@example.com"
        )
        
        #expect(client.nom == "Smith")
        #expect(client.prenom == "Jane")
        #expect(client.fullName == "Jane Smith")
    }
    
    @Test("Ecole Model: Can be instantiated")
    func testEcoleModelCreation() {
        let ecole = Ecole(
            nom: "EPITA",
            contact_email: "contact@epita.fr"
        )
        
        #expect(ecole.nom == "EPITA")
        #expect(ecole.contact_email == "contact@epita.fr")
    }
    
    // MARK: - Service Tests
    
    @Test("SupabaseService: Singleton works")
    func testSupabaseServiceSingleton() {
        let service1 = SupabaseService.shared
        let service2 = SupabaseService.shared
        
        #expect(service1 === service2)
    }
    
    @Test("KeychainService: Singleton works")
    func testKeychainServiceSingleton() {
        let service1 = KeychainService.shared
        let service2 = KeychainService.shared
        
        #expect(service1 === service2)
    }
    
    @Test("KeychainService: Save and retrieve token")
    func testKeychainSaveRetrieve() {
        let keychain = KeychainService.shared
        let testKey = "test.key.\(UUID().uuidString)"
        let testValue = "test_token_value"
        
        // Save
        let saveSuccess = keychain.saveToken(testValue, forKey: testKey)
        #expect(saveSuccess == true)
        
        // Retrieve
        let retrieved = keychain.getToken(forKey: testKey)
        #expect(retrieved == testValue)
        
        // Cleanup
        keychain.deleteToken(forKey: testKey)
    }
    
    @Test("KeychainService: Delete token")
    func testKeychainDelete() {
        let keychain = KeychainService.shared
        let testKey = "test.delete.\(UUID().uuidString)"
        let testValue = "test_value"
        
        // Save
        keychain.saveToken(testValue, forKey: testKey)
        
        // Delete
        let deleteSuccess = keychain.deleteToken(forKey: testKey)
        #expect(deleteSuccess == true)
        
        // Verify deleted
        let retrieved = keychain.getToken(forKey: testKey)
        #expect(retrieved == nil)
    }
    
    // MARK: - Extension Tests
    
    @Test("Date Extension: Display format works")
    func testDateDisplayFormat() {
        let date = Date()
        let formatted = date.displayFormat()
        
        #expect(!formatted.isEmpty)
        #expect(formatted.count == 10) // DD/MM/YYYY format
    }
    
    @Test("String Extension: Email validation works")
    func testEmailValidation() {
        #expect("test@example.com".isValidEmail == true)
        #expect("user.name@domain.co.uk".isValidEmail == true)
        #expect("notanemail".isValidEmail == false)
        #expect("invalid@".isValidEmail == false)
        #expect("@invalid.com".isValidEmail == false)
    }
    
    @Test("String Extension: Phone validation works")
    func testPhoneValidation() {
        #expect("+33123456789".isValidPhone == true)
        #expect("0123456789".isValidPhone == true)
        #expect("1234567890".isValidPhone == true)
        #expect("123".isValidPhone == false) // Too short
        #expect("abc123".isValidPhone == false) // Contains letters
    }
    
    @Test("String Extension: Date parsing works")
    func testStringToDate() {
        let dateString = "2025-12-04T10:00:00"
        let date = dateString.toDate()
        
        #expect(date != nil)
    }
}

