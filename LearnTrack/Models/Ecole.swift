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

