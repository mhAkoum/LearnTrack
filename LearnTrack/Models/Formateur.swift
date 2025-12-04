//
//  Formateur.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation

struct Formateur: Codable, Identifiable {
    let id: UUID
    var nom: String
    var prenom: String
    var email: String?
    var telephone: String?
    var type: String // "interne" or "externe"
    var specialites: String?
    var notes: String?
    var created_at: String?
    var updated_at: String?
    
    // Custom decoding to handle UUID as string from database
    enum CodingKeys: String, CodingKey {
        case id
        case nom
        case prenom
        case email
        case telephone
        case type
        case specialites
        case notes
        case created_at
        case updated_at
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID - can be string or UUID
        if let idString = try? container.decode(String.self, forKey: .id) {
            guard let uuid = UUID(uuidString: idString) else {
                throw DecodingError.dataCorruptedError(forKey: .id, in: container, debugDescription: "Invalid UUID string")
            }
            self.id = uuid
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }
        
        self.nom = try container.decode(String.self, forKey: .nom)
        self.prenom = try container.decode(String.self, forKey: .prenom)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.telephone = try container.decodeIfPresent(String.self, forKey: .telephone)
        self.type = try container.decode(String.self, forKey: .type)
        self.specialites = try container.decodeIfPresent(String.self, forKey: .specialites)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        self.updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
    }
    
    var fullName: String {
        return "\(prenom) \(nom)"
    }
    
    var isInterne: Bool {
        return type == Constants.FormateurType.interne.rawValue
    }
    
    init(
        id: UUID = UUID(),
        nom: String,
        prenom: String,
        email: String? = nil,
        telephone: String? = nil,
        type: String,
        specialites: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.nom = nom
        self.prenom = prenom
        self.email = email
        self.telephone = telephone
        self.type = type
        self.specialites = specialites
        self.notes = notes
    }
}

