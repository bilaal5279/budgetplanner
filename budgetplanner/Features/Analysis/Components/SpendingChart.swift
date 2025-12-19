import SwiftUI
import Charts
import SwiftData

struct SpendingChart: View {
    let transactions: [Transaction]
    let period: AnalysisView.TimePeriod
    
    var body: some View {
        Chart {
            ForEach(groupedData, id: \.date) { item in
                BarMark(
                    x: .value("Date", item.date, unit: unit),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.mint, Theme.Colors.mint.opacity(0.5)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(4)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: unit)) { value in
                AxisValueLabel(format: xAxisFormat)
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4]))
                    .foregroundStyle(Theme.Colors.secondaryText.opacity(0.3))
                AxisValueLabel()
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
        }
        .frame(height: 200)
    }
    
    // Logic to group transactions by day/month depending on period
    private struct ChartData {
        let date: Date
        let amount: Double
    }
    
    private var unit: Calendar.Component {
        switch period {
        case .week: return .day
        case .month: return .day
        case .year: return .month
        }
    }
    
    private var xAxisFormat: Date.FormatStyle {
        switch period {
        case .week: return .dateTime.weekday(.abbreviated)
        case .month: return .dateTime.day()
        case .year: return .dateTime.month(.abbreviated)
        }
    }
    
    private var groupedData: [ChartData] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: transactions) { transaction in
            calendar.startOfDay(for: transaction.date) // Group by day for Week/Month
            // For Year, we'd want to group by start of month, but let's keep it simple for now or refine logic
        }
        
        // This is a simplified grouping. Real implementation needs more robust date bucketing (e.g. including days with 0 spend)
        // For the "Premium" feel, we should fill in gaps with 0.
        
        return grouped.map { (key, value) in
            ChartData(date: key, amount: value.reduce(0) { $0 + $1.amount })
        }.sorted { $0.date < $1.date }
    }
}
