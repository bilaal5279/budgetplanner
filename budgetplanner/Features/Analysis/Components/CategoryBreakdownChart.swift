import SwiftUI
import Charts

struct CategoryBreakdownChart: View {
    let transactions: [Transaction]
    
    var body: some View {
        Chart(groupedData, id: \.categoryName) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .cornerRadius(5)
            .foregroundStyle(Color(hex: item.colorHex))
            .annotation(position: .overlay) {
                // Optional: Show iconic or % if slice is big enough
            }
        }
        .frame(height: 220)
        .chartBackground { proxy in
            GeometryReader { geo in
                VStack(spacing: 0) {
                    Text("Total")
                        .font(Theme.Fonts.body(12))
                        .foregroundStyle(Theme.Colors.secondaryText)
                    Text(String(format: "$%.0f", totalAmount))
                        .font(Theme.Fonts.display(24))
                        .foregroundStyle(Theme.Colors.primaryText)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
    
    private var totalAmount: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    private struct CategoryData {
        let categoryName: String
        let colorHex: String
        let amount: Double
    }
    
    private var groupedData: [CategoryData] {
        let grouped = Dictionary(grouping: transactions) { $0.category }
        
        // Filter out nil categories or handle them
        return grouped.compactMap { (category, txs) -> CategoryData? in
            guard let category = category else { return nil } // Or group as "Uncategorized"
            let total = txs.reduce(0) { $0 + $1.amount }
            if total == 0 { return nil }
            return CategoryData(categoryName: category.name, colorHex: category.colorHex, amount: total)
        }.sorted { $0.amount > $1.amount }
    }
}
