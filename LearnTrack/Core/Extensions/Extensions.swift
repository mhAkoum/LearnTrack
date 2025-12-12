
import Foundation
import SwiftUI

// MARK: - Date Extensions
extension Date {
    func formatted(using format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func displayFormat() -> String {
        return formatted(using: Constants.displayDateFormat)
    }
    
    func displayDateTimeFormat() -> String {
        return formatted(using: Constants.displayDateTimeFormat)
    }
}

// MARK: - String Extensions
extension String {
    func toDate(using format: String = Constants.dateTimeFormat) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    var isValidPhone: Bool {
        // Nettoyer le numéro (enlever espaces, tirets, parenthèses, points, +)
        let cleaned = self
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "+", with: "")
        
        // Vérifier qu'il contient exactement 10 chiffres
        let phoneRegex = "^[0-9]{10}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: cleaned)
    }
}

// MARK: - View Extensions
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

