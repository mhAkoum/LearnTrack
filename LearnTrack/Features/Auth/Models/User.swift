
import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let nom: String
    let prenom: String
    let role: String
    let actif: Bool
    
    var isAdmin: Bool {
        return role == Constants.UserRole.admin.rawValue
    }
    
    var fullName: String {
        return "\(prenom) \(nom)"
    }
}

struct UserCreate {
    var email: String
    var passwordHash: String
    var nom: String
    var prenom: String
    var role: String?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "email": email,
            "password_hash": passwordHash,
            "nom": nom,
            "prenom": prenom
        ]
        if let role = role { dict["role"] = role }
        return dict
    }
}

struct UserUpdate {
    var email: String?
    var nom: String?
    var prenom: String?
    var role: String?
    var actif: Bool?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        if let email = email { dict["email"] = email }
        if let nom = nom { dict["nom"] = nom }
        if let prenom = prenom { dict["prenom"] = prenom }
        if let role = role { dict["role"] = role }
        if let actif = actif { dict["actif"] = actif }
        return dict
    }
}

