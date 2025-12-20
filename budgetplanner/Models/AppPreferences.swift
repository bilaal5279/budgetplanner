import SwiftData
import Foundation

@Model
final class AppPreferences {
    // Singleton-like behavior via ID, but CloudKit requires UUID usually. We'll query and take the first one.
    var themeRawValue: String = "System"
    var accentRawValue: String = "Mint"
    var timestamp: Date = Date()
    
    init(themeRawValue: String = "System", accentRawValue: String = "Mint") {
        self.themeRawValue = themeRawValue
        self.accentRawValue = accentRawValue
        self.timestamp = Date()
    }
}
