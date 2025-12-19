import Foundation
import SwiftData

@Model
final class Budget {
    var month: Date = Date() // Normalized to 1st of month
    var totalLimit: Double = 0.0
    
    init(month: Date, totalLimit: Double) {
        self.month = month
        self.totalLimit = totalLimit
    }
}
