//
//  Formateur.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation
import Supabase

struct Formateur: Codable, Identifiable {
    let id: Int  // Changed from UUID to Int to match database
    var nom: String
    var prenom: String
    var email: String?
    var telephone: String?
    var specialite: String?  // Changed from specialites to specialite
    var taux_horaire: Double?  // New field
    var forme_juridique: String?  // New field
    var societe: String?  // New field
    var siret: String?  // New field
    var code_postal: String?  // New field
    var ville: String?  // New field
    var rue: String?  // New field
    var code_postal_societe: String?  // New field
    var ville_societe: String?  // New field
    var rue_societe: String?  // New field
    var exterieur: Bool?  // New field
    var nda: String?  // New field
    var created_at: String?
    var updated_at: String?
    
    // Computed properties for compatibility
    var type: String {
        // Map exterieur to type
        if let exterieur = exterieur {
            return exterieur ? "externe" : "interne"
        }
        return "interne"  // Default
    }
    
    var specialites: String? {
        return specialite
    }
    
    var notes: String? {
        // Combine multiple fields into notes if needed
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case nom
        case prenom
        case email
        case telephone
        case specialite
        case taux_horaire
        case forme_juridique
        case societe
        case siret
        case code_postal
        case ville
        case rue
        case code_postal_societe
        case ville_societe
        case rue_societe
        case exterieur
        case nda
        case created_at
        case updated_at
    }
    
    // Custom encoding to convert Bool to Int for database
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(nom, forKey: .nom)
        try container.encode(prenom, forKey: .prenom)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(telephone, forKey: .telephone)
        try container.encodeIfPresent(specialite, forKey: .specialite)
        try container.encodeIfPresent(taux_horaire, forKey: .taux_horaire)
        try container.encodeIfPresent(forme_juridique, forKey: .forme_juridique)
        try container.encodeIfPresent(societe, forKey: .societe)
        try container.encodeIfPresent(siret, forKey: .siret)
        try container.encodeIfPresent(code_postal, forKey: .code_postal)
        try container.encodeIfPresent(ville, forKey: .ville)
        try container.encodeIfPresent(rue, forKey: .rue)
        try container.encodeIfPresent(code_postal_societe, forKey: .code_postal_societe)
        try container.encodeIfPresent(ville_societe, forKey: .ville_societe)
        try container.encodeIfPresent(rue_societe, forKey: .rue_societe)
        // Convert Bool to Int (0 or 1) for database smallint column
        if let exterieur = exterieur {
            try container.encode(exterieur ? 1 : 0, forKey: .exterieur)
        } else {
            try container.encodeIfPresent(nil as Int?, forKey: .exterieur)
        }
        try container.encodeIfPresent(nda, forKey: .nda)
        try container.encodeIfPresent(created_at, forKey: .created_at)
        try container.encodeIfPresent(updated_at, forKey: .updated_at)
    }
    
    // Custom decoding to convert Int to Bool from database
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        nom = try container.decode(String.self, forKey: .nom)
        prenom = try container.decode(String.self, forKey: .prenom)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        telephone = try container.decodeIfPresent(String.self, forKey: .telephone)
        specialite = try container.decodeIfPresent(String.self, forKey: .specialite)
        taux_horaire = try container.decodeIfPresent(Double.self, forKey: .taux_horaire)
        forme_juridique = try container.decodeIfPresent(String.self, forKey: .forme_juridique)
        societe = try container.decodeIfPresent(String.self, forKey: .societe)
        siret = try container.decodeIfPresent(String.self, forKey: .siret)
        code_postal = try container.decodeIfPresent(String.self, forKey: .code_postal)
        ville = try container.decodeIfPresent(String.self, forKey: .ville)
        rue = try container.decodeIfPresent(String.self, forKey: .rue)
        code_postal_societe = try container.decodeIfPresent(String.self, forKey: .code_postal_societe)
        ville_societe = try container.decodeIfPresent(String.self, forKey: .ville_societe)
        rue_societe = try container.decodeIfPresent(String.self, forKey: .rue_societe)
        // Convert Int (0 or 1) to Bool from database smallint column
        if let exterieurInt = try? container.decodeIfPresent(Int.self, forKey: .exterieur) {
            exterieur = exterieurInt == 1
        } else if let exterieurBool = try? container.decodeIfPresent(Bool.self, forKey: .exterieur) {
            exterieur = exterieurBool
        } else {
            exterieur = nil
        }
        nda = try container.decodeIfPresent(String.self, forKey: .nda)
        created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
    }
    
    var fullName: String {
        return "\(prenom) \(nom)"
    }
    
    var isInterne: Bool {
        return type == Constants.FormateurType.interne.rawValue
    }
    
    init(
        id: Int = 0,
        nom: String,
        prenom: String,
        email: String? = nil,
        telephone: String? = nil,
        specialite: String? = nil,
        taux_horaire: Double? = nil,
        forme_juridique: String? = nil,
        societe: String? = nil,
        siret: String? = nil,
        code_postal: String? = nil,
        ville: String? = nil,
        rue: String? = nil,
        code_postal_societe: String? = nil,
        ville_societe: String? = nil,
        rue_societe: String? = nil,
        exterieur: Bool? = nil,
        nda: String? = nil
    ) {
        self.id = id
        self.nom = nom
        self.prenom = prenom
        self.email = email
        self.telephone = telephone
        self.specialite = specialite
        self.taux_horaire = taux_horaire
        self.forme_juridique = forme_juridique
        self.societe = societe
        self.siret = siret
        self.code_postal = code_postal
        self.ville = ville
        self.rue = rue
        self.code_postal_societe = code_postal_societe
        self.ville_societe = ville_societe
        self.rue_societe = rue_societe
        self.exterieur = exterieur
        self.nda = nda
    }
}

