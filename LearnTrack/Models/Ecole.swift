//
//  Ecole.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation

struct Ecole: Codable, Identifiable {
    let id: UUID
    var nom: String
    var contact_nom: String?
    var contact_email: String?
    var contact_telephone: String?
    var adresse: String?
    var notes: String?
    var created_at: String?
    var updated_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case nom
        case contact_nom
        case contact_email
        case contact_telephone
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
            print("⚠️ Ecole ID not found or invalid, generating new UUID")
            print("   Available keys: \(container.allKeys.map { $0.stringValue })")
            #endif
            self.id = UUID()
        }
        
        // Handle required fields with fallbacks
        nom = (try? container.decode(String.self, forKey: .nom)) ?? ""
        
        // Handle optional fields
        contact_nom = try container.decodeIfPresent(String.self, forKey: .contact_nom)
        contact_email = try container.decodeIfPresent(String.self, forKey: .contact_email)
        contact_telephone = try container.decodeIfPresent(String.self, forKey: .contact_telephone)
        adresse = try container.decodeIfPresent(String.self, forKey: .adresse)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
    }
    
    init(
        id: UUID = UUID(),
        nom: String,
        contact_nom: String? = nil,
        contact_email: String? = nil,
        contact_telephone: String? = nil,
        adresse: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.nom = nom
        self.contact_nom = contact_nom
        self.contact_email = contact_email
        self.contact_telephone = contact_telephone
        self.adresse = adresse
        self.notes = notes
    }
}

