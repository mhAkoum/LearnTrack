//
//  User.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    let role: String // "admin" or "user"
    
    var isAdmin: Bool {
        return role == Constants.UserRole.admin.rawValue
    }
}

