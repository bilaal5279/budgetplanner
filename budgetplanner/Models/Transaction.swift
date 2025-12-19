import Foundation
import SwiftData

@Model
final class Transaction {
    var amount: Double = 0.0
    var date: Date = Date()
    var typeRawValue: String = "Expense" // "Expense", "Income", "Transfer"
    var category: Category?
    var account: Account?
    var transferTargetAccount: Account? // Only for Transfers
    var note: String = ""
    
    var type: TransactionType {
        get { TransactionType(rawValue: typeRawValue) ?? .expense }
        set { typeRawValue = newValue.rawValue }
    }
    
    init(amount: Double, date: Date = Date(), type: TransactionType = .expense, note: String = "", category: Category? = nil, account: Account? = nil, transferTargetAccount: Account? = nil) {
        self.amount = amount
        self.date = date
        self.typeRawValue = type.rawValue
        self.note = note
        self.category = category
        self.account = account
        self.transferTargetAccount = transferTargetAccount
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case expense = "Expense"
    case income = "Income"
    case transfer = "Transfer"
}
