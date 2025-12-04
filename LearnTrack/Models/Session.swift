//
//  Session.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation

struct Session: Codable, Identifiable {
    let id: UUID
    var date_debut: String // ISO 8601 format
    var date_fin: String // ISO 8601 format
    var module: String
    var formateur_id: UUID?
    var client_id: UUID?
    var ecole_id: UUID?
    var presentiel_distanciel: String // "Présentiel" or "Distanciel"
    var prix: Double?
    var nda: String?
    var statut: String?
    var notes: String?
    var created_at: String?
    var updated_at: String?
    
    // Computed properties for display
    var dateDebut: Date? {
        return date_debut.toDate()
    }
    
    var dateFin: Date? {
        return date_fin.toDate()
    }
    
    var formattedDateDebut: String {
        return dateDebut?.displayFormat() ?? date_debut
    }
    
    var formattedDateFin: String {
        return dateFin?.displayFormat() ?? date_fin
    }
    
    var isPresentiel: Bool {
        return presentiel_distanciel == Constants.SessionType.presentiel.rawValue
    }
    
    // For creating new sessions
    init(
        id: UUID = UUID(),
        date_debut: String,
        date_fin: String,
        module: String,
        formateur_id: UUID? = nil,
        client_id: UUID? = nil,
        ecole_id: UUID? = nil,
        presentiel_distanciel: String,
        prix: Double? = nil,
        nda: String? = nil,
        statut: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date_debut = date_debut
        self.date_fin = date_fin
        self.module = module
        self.formateur_id = formateur_id
        self.client_id = client_id
        self.ecole_id = ecole_id
        self.presentiel_distanciel = presentiel_distanciel
        self.prix = prix
        self.nda = nda
        self.statut = statut
        self.notes = notes
    }
}

