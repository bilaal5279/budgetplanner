import Foundation
import SwiftData

@Model
final class BudgetHistory {
    var amount: Double = 0.0
    var startDate: Date = Date()
    
    @Relationship(inverse: \Category.budgetHistory)
    var category: Category?
    
    init(amount: Double, startDate: Date) {
        self.amount = amount
        self.startDate = startDate
    }
}
