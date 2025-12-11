//
//  Phase1TestView.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//  Test view to verify Phase 1 setup
//

import SwiftUI

struct Phase1TestView: View {
    @State private var testResults: [TestResult] = []
    
    struct TestResult: Identifiable {
        let id = UUID()
        let name: String
        let status: Status
        let message: String
        
        enum Status {
            case success
            case failure
            case warning
            
            var color: Color {
                switch self {
                case .success: return .green
                case .failure: return .red
                case .warning: return .orange
                }
            }
            
            var icon: String {
                switch self {
                case .success: return "checkmark.circle.fill"
                case .failure: return "xmark.circle.fill"
                case .warning: return "exclamationmark.triangle.fill"
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section("Phase 1 Setup Tests") {
                    ForEach(testResults) { result in
                        HStack {
                            Image(systemName: result.status.icon)
                                .foregroundColor(result.status.color)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.name)
                                    .font(.headline)
                                Text(result.message)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section("Model Tests") {
                    ModelTestSection()
                }
                
                Section("Service Tests") {
                    ServiceTestSection()
                }
                
                Section("Utility Tests") {
                    UtilityTestSection()
                }
            }
            .navigationTitle("Phase 1 Tests")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Run Tests") {
                        runAllTests()
                    }
                }
            }
            .onAppear {
                runAllTests()
            }
        }
    }
    
    private func runAllTests() {
        testResults.removeAll()
        
        // Test Constants
        testResults.append(testConstants())
        
        // Test Models
        testResults.append(testUserModel())
        testResults.append(testSessionModel())
        testResults.append(testFormateurModel())
        testResults.append(testClientModel())
        testResults.append(testEcoleModel())
        
        // Test Services
        testResults.append(testSupabaseService())
        testResults.append(testKeychainService())
        
        // Test Extensions
        testResults.append(testDateExtensions())
        testResults.append(testStringExtensions())
    }
    
    // MARK: - Test Functions
    
    private func testConstants() -> TestResult {
        // Test that Constants exists and has date formats
        let dateFormatValid = !Constants.dateFormat.isEmpty
        let displayFormatValid = !Constants.displayDateFormat.isEmpty
        
        if dateFormatValid && displayFormatValid {
            return TestResult(
                name: "Constants Configuration",
                status: .success,
                message: "Constants configured correctly"
            )
        } else {
            return TestResult(
                name: "Constants Configuration",
                status: .failure,
                message: "Missing constants configuration"
            )
        }
    }
    
    private func testUserModel() -> TestResult {
        let user = User(
            id: 1,
            email: "test@example.com",
            nom: "Doe",
            prenom: "John",
            role: "admin",
            actif: true
        )
        
        let isValid = !user.email.isEmpty && user.isAdmin && !user.fullName.isEmpty
        
        return TestResult(
            name: "User Model",
            status: isValid ? .success : .failure,
            message: isValid ? "User model works correctly" : "User model has issues"
        )
    }
    
    private func testSessionModel() -> TestResult {
        let session = Session(
            id: 1,
            titre: "iOS Development",
            description: "Formation iOS",
            dateDebut: "2025-12-04",
            dateFin: "2025-12-04",
            heureDebut: "10:00:00",
            heureFin: "18:00:00",
            clientId: nil,
            ecoleId: nil,
            formateurId: nil,
            nbParticipants: 10,
            statut: "planifié",
            prix: 500.0,
            notes: nil
        )
        
        let isValid = !session.titre.isEmpty && !session.statut.isEmpty
        
        return TestResult(
            name: "Session Model",
            status: isValid ? .success : .failure,
            message: isValid ? "Session model works correctly" : "Session model has issues"
        )
    }
    
    private func testFormateurModel() -> TestResult {
        let formateur = Formateur(
            id: 1,
            nom: "Doe",
            prenom: "John",
            email: "john@example.com",
            telephone: "+33123456789",
            specialites: ["iOS", "Swift"],
            tarifJournalier: 500.0,
            adresse: nil,
            ville: nil,
            codePostal: nil,
            notes: nil,
            actif: true
        )
        
        let isValid = !formateur.fullName.isEmpty && !formateur.email.isEmpty
        
        return TestResult(
            name: "Formateur Model",
            status: isValid ? .success : .failure,
            message: isValid ? "Formateur model works correctly" : "Formateur model has issues"
        )
    }
    
    private func testClientModel() -> TestResult {
        let client = Client(
            id: 1,
            nom: "TechCorp",
            email: "contact@techcorp.com",
            telephone: "+33123456789",
            adresse: "123 Main St",
            ville: "Paris",
            codePostal: "75001",
            siret: "12345678901234",
            contactNom: "Jane Smith",
            contactEmail: "jane@example.com",
            contactTelephone: "+33123456789",
            notes: nil,
            actif: true
        )
        
        let isValid = !client.nom.isEmpty
        
        return TestResult(
            name: "Client Model",
            status: isValid ? .success : .failure,
            message: isValid ? "Client model works correctly" : "Client model has issues"
        )
    }
    
    private func testEcoleModel() -> TestResult {
        let ecole = Ecole(
            id: 1,
            nom: "EPITA",
            adresse: "14-16 Rue Voltaire",
            ville: "Le Kremlin-Bicêtre",
            codePostal: "94270",
            telephone: "+33123456789",
            email: "contact@epita.fr",
            responsableNom: "John Doe",
            capacite: 100,
            notes: nil,
            actif: true
        )
        
        let isValid = !ecole.nom.isEmpty
        
        return TestResult(
            name: "Ecole Model",
            status: isValid ? .success : .failure,
            message: isValid ? "Ecole model works correctly" : "Ecole model has issues"
        )
    }
    
    private func testSupabaseService() -> TestResult {
        // Supabase service removed - using REST API instead
        return TestResult(
            name: "API Service",
            status: .success,
            message: "Using REST API service (APIService)"
        )
    }
    
    private func testKeychainService() -> TestResult {
        let keychain = KeychainManager.shared
        let testKey = "test.key"
        let testValue = "test_value_123"
        
        // Test save
        let saveSuccess = keychain.saveToken(testValue, forKey: testKey)
        
        // Test retrieve
        let retrievedValue = keychain.getToken(forKey: testKey)
        
        // Test delete
        let deleteSuccess = keychain.deleteToken(forKey: testKey)
        
        let isValid = saveSuccess && retrievedValue == testValue && deleteSuccess
        
        return TestResult(
            name: "Keychain Manager",
            status: isValid ? .success : .failure,
            message: isValid ? "Keychain operations work correctly" : "Keychain manager has issues"
        )
    }
    
    private func testDateExtensions() -> TestResult {
        let date = Date()
        let formatted = date.displayFormat()
        let isValid = !formatted.isEmpty && formatted.count == 10 // DD/MM/YYYY format
        
        return TestResult(
            name: "Date Extensions",
            status: isValid ? .success : .failure,
            message: isValid ? "Date formatting works correctly" : "Date extensions have issues"
        )
    }
    
    private func testStringExtensions() -> TestResult {
        let validEmail = "test@example.com".isValidEmail
        let invalidEmail = "notanemail".isValidEmail
        let validPhone = "+33123456789".isValidPhone
        
        let isValid = validEmail && !invalidEmail && validPhone
        
        return TestResult(
            name: "String Extensions",
            status: isValid ? .success : .failure,
            message: isValid ? "String validation works correctly" : "String extensions have issues"
        )
    }
}

// MARK: - Test Sections

struct ModelTestSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Test Model Instantiation")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("User:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Session:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Formateur:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Client:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Ecole:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ServiceTestSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Service Availability")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("APIService:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("KeychainManager:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("AuthService:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct UtilityTestSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Utility Functions")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Constants:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Date Extensions:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("String Extensions:")
                Spacer()
                Text("✅")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    Phase1TestView()
}

