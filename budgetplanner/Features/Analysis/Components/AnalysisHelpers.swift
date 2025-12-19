import Foundation
import SwiftUI

enum AnalysisTab: String, CaseIterable {
    case expense = "Expense"
    case income = "Income"
    case transactions = "Transactions"
}

// Simplified Period for Date Navigation
enum NavigationPeriod: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var id: String { rawValue }
}

enum AnalysisPeriod: String, CaseIterable, Identifiable {
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
    case allTime = "All Time"
    
    var id: String { rawValue }
    
    func dateRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .thisWeek:
            let start = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let end = calendar.date(byAdding: .day, value: 7, to: start)!
            return (start, end)
        case .lastWeek:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let end = startOfWeek
            let start = calendar.date(byAdding: .day, value: -7, to: end)!
            return (start, end)
        case .thisMonth:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        case .lastMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let end = startOfMonth
            let start = calendar.date(byAdding: .month, value: -1, to: end)!
            return (start, end)
        case .thisYear:
            let start = calendar.date(from: calendar.dateComponents([.year], from: now))!
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return (start, end)
        case .allTime:
            return (.distantPast, .distantFuture)
        }
    }
}

extension Date {
    func startOfPeriod(_ period: NavigationPeriod) -> Date {
        let calendar = Calendar.current
        switch period {
        case .week:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        case .month:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: self))!
        case .year:
            return calendar.date(from: calendar.dateComponents([.year], from: self))!
        }
    }
    
    func endOfPeriod(_ period: NavigationPeriod) -> Date {
        let calendar = Calendar.current
        let start = startOfPeriod(period)
        switch period {
        case .week:
            return calendar.date(byAdding: .day, value: 7, to: start)!
        case .month:
            return calendar.date(byAdding: .month, value: 1, to: start)!
        case .year:
            return calendar.date(byAdding: .year, value: 1, to: start)!
        }
    }
    
    func formatPeriod(_ period: NavigationPeriod) -> String {
        switch period {
        case .week:
            let end = Calendar.current.date(byAdding: .day, value: 6, to: self)!
            return "\(self.formatted(.dateTime.day().month())) - \(end.formatted(.dateTime.day().month()))"
        case .month:
            return self.formatted(.dateTime.month(.wide).year())
        case .year:
            return self.formatted(.dateTime.year())
        }
    }
}
