import SwiftUI
import Charts

struct CategoryPieChart: View {
    let transactions: [Transaction]
    @State private var selectedAngle: Double?
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    // Group transactions by category
    private var chartData: [(category: Category, amount: Double)] {
        let expenses = transactions.filter { $0.type == .expense }
        let grouped = Dictionary(grouping: expenses, by: { $0.category ?? Category(name: "Uncategorized", icon: "questionmark", colorHex: "808080") })
        
        let sorted = grouped.map { (cat, txs) in
            (cat, txs.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.1 > $1.1 }
        
        if subscriptionManager.isPremium {
            return sorted
        } else {
            // Free Logic: Top 2 + Rest as "Others (Upgrade)"
            if sorted.count <= 2 { return sorted }
            
            let topTwo = Array(sorted.prefix(2))
            let othersAmount = sorted.dropFirst(2).reduce(0) { $0 + $1.1 }
            
            if othersAmount > 0 {
                let othersCategory = Category(name: "Others (Locked)", icon: "lock.fill", colorHex: "E0E0E0", isCustom: false)
                return topTwo + [(othersCategory, othersAmount)]
            }
            return topTwo
        }
    }
    
    private var totalAmount: Double {
        chartData.reduce(0) { $0 + $1.amount }
    }
    
    // Find the category corresponding to the selected angle
    private var selectedCategory: (category: Category, amount: Double)? {
        guard let angle = selectedAngle else { return nil }
        
        var cumulativeTotal: Double = 0
        for item in chartData {
            cumulativeTotal += item.amount
            if angle <= cumulativeTotal {
                return item
            }
        }
        return nil
    }
    
    var body: some View {
        Chart(chartData, id: \.category.name) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.6), // Donut style
                angularInset: 1.5
            )
            .cornerRadius(4)
            .foregroundStyle(Color(hex: item.category.colorHex))
            .opacity(selectedCategory == nil || selectedCategory?.category.name == item.category.name ? 1.0 : 0.3)
        }
        .chartAngleSelection(value: $selectedAngle)
        .frame(height: 220)
        .chartLegend(position: .trailing, alignment: .center)
        .chartBackground { proxy in
            GeometryReader { geo in
                VStack(spacing: 4) {
                    if let selected = selectedCategory {
                        // Show Selected Category Details
                        Text(selected.category.name)
                            .font(.caption.bold())
                            .foregroundStyle(Theme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                        
                        Text(selected.amount.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                            .font(.headline)
                            .foregroundStyle(Theme.Colors.primaryText)
                        
                        Text("\((selected.amount / totalAmount * 100).formatted(.number.precision(.fractionLength(0))))%")
                            .font(.caption2)
                            .foregroundStyle(Color(hex: selected.category.colorHex))
                    } else {
                        // Show Total
                        Text("Total")
                            .font(.caption)
                            .foregroundStyle(Theme.Colors.secondaryText)
                        Text(totalAmount.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                            .font(.headline)
                            .foregroundStyle(Theme.Colors.primaryText)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}
