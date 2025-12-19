import Foundation
import SwiftData

struct TrendResult {
    let percentage: Double
    let isIncrease: Bool
    let difference: Double
}

extension AnalysisPeriod {
    // Helper to get the previous period range based on the current one
    // Note: This relies on the current `startOfPeriod` logic in `Date`
    func previousPeriodRange(from currentStart: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        switch self {
        case .thisWeek:
            let prevStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentStart)!
            let prevEnd = currentStart
            return (prevStart, prevEnd)
        case .thisMonth: // Represents "Month" granularity
            let prevStart = calendar.date(byAdding: .month, value: -1, to: currentStart)!
            let prevEnd = currentStart
            return (prevStart, prevEnd)
        case .thisYear:
            let prevStart = calendar.date(byAdding: .year, value: -1, to: currentStart)!
            let prevEnd = currentStart
            return (prevStart, prevEnd)
        default:
            return (.distantPast, .distantPast)
        }
    }
}

class TrendCalculator {
    static func calculateTrend(current: Double, previous: Double) -> TrendResult? {
        guard previous > 0 else { return nil } // Avoid division by zero or infinite growth from 0
        let diff = current - previous
        let percentage = (diff / previous) * 100
        return TrendResult(
            percentage: abs(percentage),
            isIncrease: percentage > 0,
            difference: diff
        )
    }
}
