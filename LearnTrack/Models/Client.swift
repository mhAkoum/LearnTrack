//
//  Client.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation

struct Client: Codable, Identifiable {
    let id: UUID
    var nom: String
    var prenom: String
    var email: String?
    var telephone: String?
    var entreprise: String?
    var adresse: String?
    var notes: String?
    var created_at: String?
    var updated_at: String?
    
    var fullName: String {
        return "\(prenom) \(nom)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case nom
        case prenom
        case email
        case telephone
        case entreprise
        case adresse
        case notes
        case created_at
        case updated_at
    }
    
    // Flexible decoding to handle different database structures
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle ID: can be Int, UUID, or String - be very flexible
        if let uuid = try? container.decode(UUID.self, forKey: .id) {
            self.id = uuid
        } else if let uuidString = try? container.decode(String.self, forKey: .id) {
            if let uuid = UUID(uuidString: uuidString) {
                self.id = uuid
            } else if let intId = Int(uuidString) {
                // String contains an integer, convert to UUID
                var uuidBytes = [UInt8](repeating: 0, count: 16)
                withUnsafeBytes(of: intId.bigEndian) { bytes in
                    uuidBytes.replaceSubrange(12..<16, with: bytes)
                }
                self.id = UUID(uuid: uuid_t(uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
                                            uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
                                            uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11],
                                            uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]))
            } else {
                // Invalid string, generate new UUID
                self.id = UUID()
            }
        } else if let intId = try? container.decode(Int.self, forKey: .id) {
            // Int ID: convert to UUID deterministically
            var uuidBytes = [UInt8](repeating: 0, count: 16)
            withUnsafeBytes(of: intId.bigEndian) { bytes in
                uuidBytes.replaceSubrange(12..<16, with: bytes)
            }
            self.id = UUID(uuid: uuid_t(uuidBytes[0], uuidBytes[1], uuidBytes[2], uuidBytes[3],
                                        uuidBytes[4], uuidBytes[5], uuidBytes[6], uuidBytes[7],
                                        uuidBytes[8], uuidBytes[9], uuidBytes[10], uuidBytes[11],
                                        uuidBytes[12], uuidBytes[13], uuidBytes[14], uuidBytes[15]))
        } else {
            // Fallback: generate new UUID if ID is missing or invalid
            #if DEBUG
            print("⚠️ Client ID not found or invalid, generating new UUID")
            print("   Available keys: \(container.allKeys.map { $0.stringValue })")
            #endif
            self.id = UUID()
        }
        
        // Debug: Print all available keys
        #if DEBUG
        let allKeys = container.allKeys.map { $0.stringValue }
        print("📋 Client decoding - Available keys: \(allKeys)")
        #endif
        
        // Handle required fields - decode with proper error handling
        // Try to decode, but handle null/missing values gracefully
        do {
            if let nomValue = try container.decodeIfPresent(String.self, forKey: .nom) {
                nom = nomValue
            } else {
                #if DEBUG
                print("⚠️ Client 'nom' is null")
                #endif
                nom = ""
            }
        } catch {
            #if DEBUG
            print("⚠️ Client 'nom' decode error: \(error)")
            #endif
            nom = ""
        }
        
        do {
            if let prenomValue = try container.decodeIfPresent(String.self, forKey: .prenom) {
                prenom = prenomValue
            } else {
                #if DEBUG
                print("⚠️ Client 'prenom' is null")
                #endif
                prenom = ""
            }
        } catch {
            #if DEBUG
            print("⚠️ Client 'prenom' decode error: \(error)")
            #endif
            prenom = ""
        }
        
        #if DEBUG
        if !nom.isEmpty || !prenom.isEmpty {
            print("📝 Client decoded - nom: '\(nom)', prenom: '\(prenom)'")
        } else {
            print("❌ Client decoded with EMPTY nom and prenom!")
        }
        #endif
        
        // Handle optional fields
        email = try container.decodeIfPresent(String.self, forKey: .email)
        telephone = try container.decodeIfPresent(String.self, forKey: .telephone)
        entreprise = try container.decodeIfPresent(String.self, forKey: .entreprise)
        adresse = try container.decodeIfPresent(String.self, forKey: .adresse)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
    }
    
    init(
        id: UUID = UUID(),
        nom: String,
        prenom: String,
        email: String? = nil,
        telephone: String? = nil,
        entreprise: String? = nil,
        adresse: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.nom = nom
        self.prenom = prenom
        self.email = email
        self.telephone = telephone
        self.entreprise = entreprise
        self.adresse = adresse
        self.notes = notes
    }
}

