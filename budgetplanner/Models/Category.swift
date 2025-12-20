import Foundation
import SwiftData

@Model
final class Category {
    var name: String = "New Category"
    var icon: String = "questionmark.circle"
    var colorHex: String = "00C48C"
    var budgetLimit: Double?
    var typeRawValue: String = "Expense" // Backing storage for TransactionType
    
    var type: TransactionType {
        get { TransactionType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    // New property to distinguish default vs custom
    var isCustom: Bool = true
    
    // CloudKit requirement: Optional relationship or default value handling recommended, 
    // but for 'to-many' it is usually [Transaction]? or [Transaction] with default = []
    // To match Phase 3 plan:
    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction]? = []
    
    @Relationship(deleteRule: .cascade)
    var budgetHistory: [BudgetHistory]? = []
    
    init(name: String, icon: String, colorHex: String, budgetLimit: Double? = nil, type: TransactionType = .expense, isCustom: Bool = true) {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.budgetLimit = budgetLimit
        self.typeRawValue = type.rawValue
        self.isCustom = isCustom
    }
}
