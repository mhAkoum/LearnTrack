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
    let presentielDistanciel: String? // Stocke "P" ou "D" depuis la DB, mais affiche "Présentiel" ou "Distanciel"

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
        case presentielDistanciel = "presentiel_distanciel"
    }
    
    // Propriété calculée pour l'affichage
    var presentielDistancielDisplay: String? {
        guard let value = presentielDistanciel else { return nil }
        if value.uppercased() == "P" {
            return "Présentiel"
        } else if value.uppercased() == "D" {
            return "Distanciel"
        }
        return value // Si ce n'est ni P ni D, retourner la valeur telle quelle
    }
    
    var isPresentiel: Bool {
        return presentielDistanciel?.uppercased() == "P"
    }
    
    var isDistanciel: Bool {
        return presentielDistanciel?.uppercased() == "D"
    }
    
    var presentielEmoji: String {
        if isPresentiel {
            return "🏢"
        } else if isDistanciel {
            return "💻"
        }
        return "❓"
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
    var heureDebut: String?  // Format: "HH:MM"
    var heureFin: String?    // Format: "HH:MM"
    var clientId: Int?
    var ecoleId: Int?
    var formateurId: Int?
    var nbParticipants: Int?
    var statut: String?
    var prix: Double?
    var notes: String?
    var presentielDistanciel: String? // "Présentiel" ou "Distanciel"

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "titre": titre,
            "date_debut": dateDebut,
            "date_fin": dateFin
        ]
        if let description = description { dict["description"] = description }
        if let heureDebut = heureDebut { 
            // Convertir HH:MM en HH:MM:SS si nécessaire
            let formattedHeure = heureDebut.contains(":") && heureDebut.split(separator: ":").count == 2 ? "\(heureDebut):00" : heureDebut
            dict["heure_debut"] = formattedHeure
        }
        if let heureFin = heureFin { 
            let formattedHeure = heureFin.contains(":") && heureFin.split(separator: ":").count == 2 ? "\(heureFin):00" : heureFin
            dict["heure_fin"] = formattedHeure
        }
        if let clientId = clientId { dict["client_id"] = clientId }
        if let ecoleId = ecoleId { dict["ecole_id"] = ecoleId }
        if let formateurId = formateurId { dict["formateur_id"] = formateurId }
        if let nbParticipants = nbParticipants { dict["nb_participants"] = nbParticipants }
        if let statut = statut { dict["statut"] = statut }
        if let prix = prix { dict["prix"] = prix }
        if let notes = notes { dict["notes"] = notes }
        if let presentielDistanciel = presentielDistanciel { 
            // Convertir "Présentiel" ou "Distanciel" en "P" ou "D"
            let modeCode: String
            if presentielDistanciel.lowercased() == "présentiel" || presentielDistanciel.lowercased() == "presentiel" {
                modeCode = "P"
            } else if presentielDistanciel.lowercased() == "distanciel" {
                modeCode = "D"
            } else {
                // Si c'est déjà "P" ou "D", utiliser tel quel
                modeCode = presentielDistanciel.uppercased()
            }
            dict["presentiel_distanciel"] = modeCode
        }
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
    var presentielDistanciel: String?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let titre = titre { dict["titre"] = titre }
        if let description = description { dict["description"] = description }
        if let dateDebut = dateDebut { dict["date_debut"] = dateDebut }
        if let dateFin = dateFin { dict["date_fin"] = dateFin }
        if let heureDebut = heureDebut { 
            let formattedHeure = heureDebut.contains(":") && heureDebut.split(separator: ":").count == 2 ? "\(heureDebut):00" : heureDebut
            dict["heure_debut"] = formattedHeure
        }
        if let heureFin = heureFin { 
            let formattedHeure = heureFin.contains(":") && heureFin.split(separator: ":").count == 2 ? "\(heureFin):00" : heureFin
            dict["heure_fin"] = formattedHeure
        }
        if let clientId = clientId { dict["client_id"] = clientId }
        if let ecoleId = ecoleId { dict["ecole_id"] = ecoleId }
        if let formateurId = formateurId { dict["formateur_id"] = formateurId }
        if let nbParticipants = nbParticipants { dict["nb_participants"] = nbParticipants }
        if let statut = statut { dict["statut"] = statut }
        if let prix = prix { dict["prix"] = prix }
        if let notes = notes { dict["notes"] = notes }
        if let presentielDistanciel = presentielDistanciel { 
            // Convertir "Présentiel" ou "Distanciel" en "P" ou "D"
            let modeCode: String
            if presentielDistanciel.lowercased() == "présentiel" || presentielDistanciel.lowercased() == "presentiel" {
                modeCode = "P"
            } else if presentielDistanciel.lowercased() == "distanciel" {
                modeCode = "D"
            } else {
                // Si c'est déjà "P" ou "D", utiliser tel quel
                modeCode = presentielDistanciel.uppercased()
            }
            dict["presentiel_distanciel"] = modeCode
        }
        return dict
    }
}

