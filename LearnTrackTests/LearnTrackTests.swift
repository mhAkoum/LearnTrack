//
//  LearnTrackTests.swift
//  LearnTrackTests
//
//  Created by mohmmad akoum on 04/12/2025.
//

import Foundation
import Testing
@testable import LearnTrack

struct LearnTrackTests {
    
    @Test("APIService: Singleton works")
    func testAPIServiceSingleton() {
        let service1 = APIService.shared
        let service2 = APIService.shared
        
        #expect(service1 === service2)
    }
    
    @Test("Formateur: fullName computed property")
    func testFormateurFullName() throws {
        let json = """
        {
            "id": 1,
            "nom": "Doe",
            "prenom": "John",
            "email": "john@example.com",
            "actif": true
        }
        """.data(using: .utf8)!
        
        let formateur = try JSONDecoder().decode(Formateur.self, from: json)
        #expect(formateur.fullName == "John Doe")
    }
}
