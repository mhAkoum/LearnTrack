
import UIKit

/// Manager for clipboard operations (SHARE-05)
class ClipboardManager {
    static let shared = ClipboardManager()
    
    private init() {}
    
    /// Copy text to clipboard
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    /// Get text from clipboard
    func getFromClipboard() -> String? {
        return UIPasteboard.general.string
    }
    
    /// Check if clipboard has text
    func hasText() -> Bool {
        return UIPasteboard.general.hasStrings
    }
}

