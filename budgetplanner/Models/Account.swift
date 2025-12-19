import Foundation
import SwiftData

@Model
final class Account {
    var name: String = "Bank Account"
    var balance: Double = 0.0
    var icon: String = "creditcard.fill"
    var colorHex: String = "54A0FF" // Blue default
    var sortOrder: Int = 0
    var isArchived: Bool = false
    var createdAt: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var transactions: [Transaction]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \Transaction.transferTargetAccount)
    var incomingTransfers: [Transaction]? = []
    
    init(name: String, balance: Double = 0.0, icon: String = "creditcard.fill", colorHex: String = "54A0FF", sortOrder: Int = 0) {
        self.name = name
        self.balance = balance
        self.icon = icon
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.createdAt = Date()
    }
}
