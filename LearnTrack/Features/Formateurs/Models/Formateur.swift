
import Foundation

struct Formateur: Codable, Identifiable {
    let id: Int
    let nom: String
    let prenom: String
    let email: String
    let telephone: String?
    let specialites: [String]?
    let tarifJournalier: Double?
    let adresse: String?
    let ville: String?
    let codePostal: String?
    let notes: String?
    let actif: Bool

    enum CodingKeys: String, CodingKey {
        case id, nom, prenom, email, telephone, specialites, adresse, ville, notes, actif
        case tarifJournalier = "tarif_journalier"
        case codePostal = "code_postal"
    }
    
    var fullName: String {
        return "\(prenom) \(nom)"
    }
}

struct FormateurCreate {
    var nom: String
    var prenom: String
    var email: String
    var telephone: String?
    var specialites: [String]?
    var tarifJournalier: Double?
    var adresse: String?
    var ville: String?
    var codePostal: String?
    var notes: String?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = ["nom": nom, "prenom": prenom, "email": email]
        if let telephone = telephone { dict["telephone"] = telephone }
        if let specialites = specialites { dict["specialites"] = specialites }
        if let tarifJournalier = tarifJournalier { dict["tarif_journalier"] = tarifJournalier }
        if let adresse = adresse { dict["adresse"] = adresse }
        if let ville = ville { dict["ville"] = ville }
        if let codePostal = codePostal { dict["code_postal"] = codePostal }
        if let notes = notes { dict["notes"] = notes }
        return dict
    }
}

struct FormateurUpdate {
    var nom: String?
    var prenom: String?
    var email: String?
    var telephone: String?
    var specialites: [String]?
    var tarifJournalier: Double?
    var adresse: String?
    var ville: String?
    var codePostal: String?
    var notes: String?
    var actif: Bool?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let nom = nom { dict["nom"] = nom }
        if let prenom = prenom { dict["prenom"] = prenom }
        if let email = email { dict["email"] = email }
        if let telephone = telephone { dict["telephone"] = telephone }
        if let specialites = specialites { dict["specialites"] = specialites }
        if let tarifJournalier = tarifJournalier { dict["tarif_journalier"] = tarifJournalier }
        if let adresse = adresse { dict["adresse"] = adresse }
        if let ville = ville { dict["ville"] = ville }
        if let codePostal = codePostal { dict["code_postal"] = codePostal }
        if let notes = notes { dict["notes"] = notes }
        if let actif = actif { dict["actif"] = actif }
        return dict
    }
}

