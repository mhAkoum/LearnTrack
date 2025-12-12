
import Foundation

struct Ecole: Codable, Identifiable {
    let id: Int
    let nom: String
    let adresse: String?
    let ville: String?
    let codePostal: String?
    let telephone: String?
    let email: String?
    let responsableNom: String?
    let capacite: Int?
    let notes: String?
    let actif: Bool

    enum CodingKeys: String, CodingKey {
        case id, nom, adresse, ville, telephone, email, capacite, notes, actif
        case codePostal = "code_postal"
        case responsableNom = "responsable_nom"
    }
}

struct EcoleCreate {
    var nom: String
    var adresse: String?
    var ville: String?
    var codePostal: String?
    var telephone: String?
    var email: String?
    var responsableNom: String?
    var capacite: Int?
    var notes: String?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = ["nom": nom]
        if let adresse = adresse { dict["adresse"] = adresse }
        if let ville = ville { dict["ville"] = ville }
        if let codePostal = codePostal { dict["code_postal"] = codePostal }
        if let telephone = telephone { dict["telephone"] = telephone }
        if let email = email { dict["email"] = email }
        if let responsableNom = responsableNom { dict["responsable_nom"] = responsableNom }
        if let capacite = capacite { dict["capacite"] = capacite }
        if let notes = notes { dict["notes"] = notes }
        return dict
    }
}

struct EcoleUpdate {
    var nom: String?
    var adresse: String?
    var ville: String?
    var codePostal: String?
    var telephone: String?
    var email: String?
    var responsableNom: String?
    var capacite: Int?
    var notes: String?
    var actif: Bool?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let nom = nom { dict["nom"] = nom }
        if let adresse = adresse { dict["adresse"] = adresse }
        if let ville = ville { dict["ville"] = ville }
        if let codePostal = codePostal { dict["code_postal"] = codePostal }
        if let telephone = telephone { dict["telephone"] = telephone }
        if let email = email { dict["email"] = email }
        if let responsableNom = responsableNom { dict["responsable_nom"] = responsableNom }
        if let capacite = capacite { dict["capacite"] = capacite }
        if let notes = notes { dict["notes"] = notes }
        if let actif = actif { dict["actif"] = actif }
        return dict
    }
}

