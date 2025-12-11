//
//  Constants.swift
//  LearnTrack
//
//  Created on 04/12/2025.
//

import Foundation

enum Constants {
    // MARK: - Date Formats
    static let dateFormat = "yyyy-MM-dd"
    static let dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss"
    static let displayDateFormat = "dd/MM/yyyy"
    static let displayDateTimeFormat = "dd/MM/yyyy HH:mm"
    
    // MARK: - User Roles
    enum UserRole: String {
        case admin = "admin"
        case user = "user"
    }
    
    // MARK: - Session Types
    enum SessionType: String {
        case presentiel = "Présentiel"
        case distanciel = "Distanciel"
    }
    
    // MARK: - Formateur Types
    enum FormateurType: String {
        case interne = "interne"
        case externe = "externe"
    }
}

