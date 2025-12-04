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

