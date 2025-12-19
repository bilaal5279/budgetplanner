import Foundation
import SwiftData

@Model
final class Category {
    var name: String = "New Category"
    var icon: String = "questionmark.circle"
    var colorHex: String = "00C48C"
    var budgetLimit: Double?
    
    // CloudKit requirement: Optional relationship or default value handling recommended, 
    // but for 'to-many' it is usually [Transaction]? or [Transaction] with default = []
    // To match Phase 3 plan:
    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction]? = []
    
    init(name: String, icon: String, colorHex: String, budgetLimit: Double? = nil) {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.budgetLimit = budgetLimit
    }
}
