import SwiftUI
import Charts
import SwiftData

struct SpendingChart: View {
    let transactions: [Transaction]
    let period: AnalysisPeriod
    
    // Optional override for navigation
    var customDateRange: (start: Date, end: Date)? = nil
    
    @Binding var selectedDate: Date?
    @Binding var selectedAmount: Double?
    
    var body: some View {
        Chart {
            ForEach(chartData, id: \.date) { item in
                BarMark(
                    x: .value("Date", item.date, unit: unit),
                    y: .value("Amount", item.amount)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.Colors.mint, Theme.Colors.mint.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(6)
                .opacity(selectedDate == nil || (selectedDate != nil && Calendar.current.isDate(selectedDate!, equalTo: item.date, toGranularity: unit)) ? 1.0 : 0.4)
            }
            
            if let selected = selectedDate {
                RuleMark(x: .value("Selected", selected, unit: unit))
                    .foregroundStyle(Theme.Colors.secondaryText.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                    
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                // Minimalist X Axis
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date, format: xAxisFormat)
                    }
                    .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
        }
        .chartYAxis(.hidden)
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard let plotFrame = proxy.plotFrame else { return }
                                let x = value.location.x - geo[plotFrame].origin.x
                                
                                if let date: Date = proxy.value(atX: x) {
                                    // Find nearest bin
                                    // Snap to unit
                                    // This is rough snapping. Using chartData to find nearest is better.
                                    
                                    if let nearest = chartData.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) }) {
                                        selectedDate = nearest.date
                                        selectedAmount = nearest.amount
                                    }
                                }
                            }
                            .onEnded { _ in
                                selectedDate = nil
                                selectedAmount = nil
                            }
                    )
            }
        }
        .frame(height: 220)
    }
    
    // Logic to group transactions by day/month depending on period
    private struct ChartData {
        let date: Date
        let amount: Double
    }
    
    private var unit: Calendar.Component {
        switch period {
        case .thisWeek, .lastWeek: return .day
        case .thisMonth, .lastMonth: return .day
        case .thisYear, .allTime: return .month
        }
    }
    
    private var xAxisFormat: Date.FormatStyle {
        switch period {
        case .thisWeek, .lastWeek: 
            return .dateTime.weekday(.abbreviated)
        case .thisMonth, .lastMonth: 
            return .dateTime.day()
        case .thisYear: 
            return .dateTime.month(.abbreviated)
        case .allTime: 
            return .dateTime.month(.narrow).year(.twoDigits)
        }
    }
    
    private var chartData: [ChartData] {
        let calendar = Calendar.current
        let range = period.dateRange()
        
        let grouped = Dictionary(grouping: transactions) { transaction in
            if period == .thisYear || period == .allTime {
                return calendar.date(from: calendar.dateComponents([.year, .month], from: transaction.date))!
            } else {
                return calendar.startOfDay(for: transaction.date)
            }
        }
        
        var finalData: [ChartData] = []
        var currentDate = range.start
        
        // Fix: Ensure we don't go infinite.
        // For weeks/months, adding days is safe.
        
        while currentDate < range.end {
            let key = currentDate
            let amount = grouped[key]?.reduce(0) { $0 + $1.amount } ?? 0
            finalData.append(ChartData(date: currentDate, amount: amount))
            
            if period == .thisYear || period == .allTime {
                 if let next = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                     currentDate = next
                 } else { break }
            } else {
                 if let next = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                     currentDate = next
                 } else { break }
            }
        }
        
        return finalData
    }
}
