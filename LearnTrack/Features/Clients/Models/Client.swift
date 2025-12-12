
import Foundation

struct Client: Codable, Identifiable {
    let id: Int
    let nom: String
    let email: String?
    let telephone: String?
    let adresse: String?
    let ville: String?
    let codePostal: String?
    let siret: String?
    let contactNom: String?
    let contactEmail: String?
    let contactTelephone: String?
    let notes: String?
    let actif: Bool

    enum CodingKeys: String, CodingKey {
        case id, nom, email, telephone, adresse, ville, siret, notes, actif
        case codePostal = "code_postal"
        case contactNom = "contact_nom"
        case contactEmail = "contact_email"
        case contactTelephone = "contact_telephone"
    }
}

struct ClientCreate {
    var nom: String
    var email: String?
    var telephone: String?
    var adresse: String?
    var ville: String?
    var codePostal: String?
    var siret: String?
    var contactNom: String?
    var contactEmail: String?
    var contactTelephone: String?
    var notes: String?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = ["nom": nom]
        if let email = email { dict["email"] = email }
        if let telephone = telephone { dict["telephone"] = telephone }
        if let adresse = adresse { dict["adresse"] = adresse }
        if let ville = ville { dict["ville"] = ville }
        if let codePostal = codePostal { dict["code_postal"] = codePostal }
        if let siret = siret { dict["siret"] = siret }
        if let contactNom = contactNom { dict["contact_nom"] = contactNom }
        if let contactEmail = contactEmail { dict["contact_email"] = contactEmail }
        if let contactTelephone = contactTelephone { dict["contact_telephone"] = contactTelephone }
        if let notes = notes { dict["notes"] = notes }
        return dict
    }
}

struct ClientUpdate {
    var nom: String?
    var email: String?
    var telephone: String?
    var adresse: String?
    var ville: String?
    var codePostal: String?
    var siret: String?
    var contactNom: String?
    var contactEmail: String?
    var contactTelephone: String?
    var notes: String?
    var actif: Bool?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let nom = nom { dict["nom"] = nom }
        if let email = email { dict["email"] = email }
        if let telephone = telephone { dict["telephone"] = telephone }
        if let adresse = adresse { dict["adresse"] = adresse }
        if let ville = ville { dict["ville"] = ville }
        if let codePostal = codePostal { dict["code_postal"] = codePostal }
        if let siret = siret { dict["siret"] = siret }
        if let contactNom = contactNom { dict["contact_nom"] = contactNom }
        if let contactEmail = contactEmail { dict["contact_email"] = contactEmail }
        if let contactTelephone = contactTelephone { dict["contact_telephone"] = contactTelephone }
        if let notes = notes { dict["notes"] = notes }
        if let actif = actif { dict["actif"] = actif }
        return dict
    }
}

