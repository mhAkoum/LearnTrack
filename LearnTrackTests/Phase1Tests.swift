//
//  Phase1Tests.swift
//  LearnTrackTests
//
//  Created on 04/12/2025.
//  Minimal unit tests for LearnTrack REST API architecture
//

import Foundation
import Testing
@testable import LearnTrack

struct Phase1Tests {
    
    // MARK: - Model Tests
    
    @Test("Formateur Model: Can be instantiated and decoded from JSON")
    func testFormateurModel() throws {
        let json = """
        {
            "id": 1,
            "nom": "Doe",
            "prenom": "John",
            "email": "john@example.com",
            "telephone": "0123456789",
            "specialites": ["iOS", "Swift"],
            "tarif_journalier": 500.0,
            "actif": true
        }
        """.data(using: .utf8)!
        
        let formateur = try JSONDecoder().decode(Formateur.self, from: json)
        
        #expect(formateur.id == 1)
        #expect(formateur.nom == "Doe")
        #expect(formateur.prenom == "John")
        #expect(formateur.email == "john@example.com")
        #expect(formateur.fullName == "John Doe")
        #expect(formateur.actif == true)
    }
    
    @Test("Client Model: Can be instantiated and decoded from JSON")
    func testClientModel() throws {
        let json = """
        {
            "id": 1,
            "nom": "Acme Corp",
            "email": "contact@acme.com",
            "telephone": "0123456789",
            "ville": "Paris",
            "code_postal": "75001",
            "actif": true
        }
        """.data(using: .utf8)!
        
        let client = try JSONDecoder().decode(Client.self, from: json)
        
        #expect(client.id == 1)
        #expect(client.nom == "Acme Corp")
        #expect(client.email == "contact@acme.com")
        #expect(client.ville == "Paris")
        #expect(client.actif == true)
    }
    
    @Test("Ecole Model: Can be instantiated and decoded from JSON")
    func testEcoleModel() throws {
        let json = """
        {
            "id": 1,
            "nom": "EPITA",
            "adresse": "14-16 rue Voltaire",
            "ville": "Paris",
            "code_postal": "94270",
            "email": "contact@epita.fr",
            "responsable_nom": "John Doe",
            "capacite": 100,
            "actif": true
        }
        """.data(using: .utf8)!
        
        let ecole = try JSONDecoder().decode(Ecole.self, from: json)
        
        #expect(ecole.id == 1)
        #expect(ecole.nom == "EPITA")
        #expect(ecole.ville == "Paris")
        #expect(ecole.capacite == 100)
        #expect(ecole.actif == true)
    }
    
    @Test("Session Model: Can be instantiated and decoded from JSON")
    func testSessionModel() throws {
        let json = """
        {
            "id": 1,
            "titre": "iOS Development",
            "description": "Formation Swift",
            "date_debut": "2025-12-04",
            "date_fin": "2025-12-06",
            "heure_debut": "09:00:00",
            "heure_fin": "17:00:00",
            "client_id": 1,
            "ecole_id": 1,
            "formateur_id": 1,
            "nb_participants": 20,
            "statut": "planifie",
            "prix": 5000.0
        }
        """.data(using: .utf8)!
        
        let session = try JSONDecoder().decode(Session.self, from: json)
        
        #expect(session.id == 1)
        #expect(session.titre == "iOS Development")
        #expect(session.dateDebut == "2025-12-04")
        #expect(session.statut == "planifie")
        #expect(session.clientId == 1)
    }
    
    // MARK: - Create/Update DTO Tests
    
    @Test("FormateurCreate: toDictionary works")
    func testFormateurCreateToDictionary() {
        let create = FormateurCreate(
            nom: "Doe",
            prenom: "John",
            email: "john@example.com",
            specialites: ["iOS", "Swift"],
            tarifJournalier: 500.0
        )
        
        let dict = create.toDictionary()
        
        #expect(dict["nom"] as? String == "Doe")
        #expect(dict["prenom"] as? String == "John")
        #expect(dict["tarif_journalier"] as? Double == 500.0)
    }
    
    @Test("ClientCreate: toDictionary works")
    func testClientCreateToDictionary() {
        let create = ClientCreate(
            nom: "Acme Corp",
            email: "contact@acme.com",
            ville: "Paris",
            codePostal: "75001"
        )
        
        let dict = create.toDictionary()
        
        #expect(dict["nom"] as? String == "Acme Corp")
        #expect(dict["code_postal"] as? String == "75001")
    }
    
    // MARK: - KeychainManager Tests
    
    @Test("KeychainManager: Singleton works")
    func testKeychainManagerSingleton() {
        let manager1 = KeychainManager.shared
        let manager2 = KeychainManager.shared
        
        #expect(manager1 === manager2)
    }
    
    @Test("KeychainManager: Save and retrieve token")
    func testKeychainSaveRetrieve() {
        let keychain = KeychainManager.shared
        let testKey = "test.key.\(UUID().uuidString)"
        let testValue = "test_token_value"
        
        // Save
        let saveSuccess = keychain.saveToken(testValue, forKey: testKey)
        #expect(saveSuccess == true)
        
        // Retrieve
        let retrieved = keychain.getToken(forKey: testKey)
        #expect(retrieved == testValue)
        
        // Cleanup
        _ = keychain.deleteToken(forKey: testKey)
    }
    
    @Test("KeychainManager: Delete token")
    func testKeychainDelete() {
        let keychain = KeychainManager.shared
        let testKey = "test.delete.\(UUID().uuidString)"
        let testValue = "test_value"
        
        // Save
        _ = keychain.saveToken(testValue, forKey: testKey)
        
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
}

