//
//  Session.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation

struct Session: Codable, Identifiable {
    let id: Int
    let titre: String
    let description: String?
    let dateDebut: String
    let dateFin: String
    let heureDebut: String?
    let heureFin: String?
    let clientId: Int?
    let ecoleId: Int?
    let formateurId: Int?
    let nbParticipants: Int?
    let statut: String
    let prix: Double?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id, titre, description, statut, prix, notes
        case dateDebut = "date_debut"
        case dateFin = "date_fin"
        case heureDebut = "heure_debut"
        case heureFin = "heure_fin"
        case clientId = "client_id"
        case ecoleId = "ecole_id"
        case formateurId = "formateur_id"
        case nbParticipants = "nb_participants"
    }
    
    // Computed properties for display
    var dateDebutDate: Date? {
        return dateDebut.toDate(using: Constants.dateFormat)
    }
    
    var dateFinDate: Date? {
        return dateFin.toDate(using: Constants.dateFormat)
    }
    
    var formattedDateDebut: String {
        return dateDebutDate?.displayFormat() ?? dateDebut
    }
    
    var formattedDateFin: String {
        return dateFinDate?.displayFormat() ?? dateFin
    }
}

struct SessionCreate {
    var titre: String
    var description: String?
    var dateDebut: String  // Format: "YYYY-MM-DD"
    var dateFin: String
    var heureDebut: String?  // Format: "HH:MM:SS"
    var heureFin: String?
    var clientId: Int?
    var ecoleId: Int?
    var formateurId: Int?
    var nbParticipants: Int?
    var statut: String?
    var prix: Double?
    var notes: String?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "titre": titre,
            "date_debut": dateDebut,
            "date_fin": dateFin
        ]
        if let description = description { dict["description"] = description }
        if let heureDebut = heureDebut { dict["heure_debut"] = heureDebut }
        if let heureFin = heureFin { dict["heure_fin"] = heureFin }
        if let clientId = clientId { dict["client_id"] = clientId }
        if let ecoleId = ecoleId { dict["ecole_id"] = ecoleId }
        if let formateurId = formateurId { dict["formateur_id"] = formateurId }
        if let nbParticipants = nbParticipants { dict["nb_participants"] = nbParticipants }
        if let statut = statut { dict["statut"] = statut }
        if let prix = prix { dict["prix"] = prix }
        if let notes = notes { dict["notes"] = notes }
        return dict
    }
}

struct SessionUpdate {
    var titre: String?
    var description: String?
    var dateDebut: String?
    var dateFin: String?
    var heureDebut: String?
    var heureFin: String?
    var clientId: Int?
    var ecoleId: Int?
    var formateurId: Int?
    var nbParticipants: Int?
    var statut: String?
    var prix: Double?
    var notes: String?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let titre = titre { dict["titre"] = titre }
        if let description = description { dict["description"] = description }
        if let dateDebut = dateDebut { dict["date_debut"] = dateDebut }
        if let dateFin = dateFin { dict["date_fin"] = dateFin }
        if let heureDebut = heureDebut { dict["heure_debut"] = heureDebut }
        if let heureFin = heureFin { dict["heure_fin"] = heureFin }
        if let clientId = clientId { dict["client_id"] = clientId }
        if let ecoleId = ecoleId { dict["ecole_id"] = ecoleId }
        if let formateurId = formateurId { dict["formateur_id"] = formateurId }
        if let nbParticipants = nbParticipants { dict["nb_participants"] = nbParticipants }
        if let statut = statut { dict["statut"] = statut }
        if let prix = prix { dict["prix"] = prix }
        if let notes = notes { dict["notes"] = notes }
        return dict
    }
}

