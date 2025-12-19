import SwiftUI
import Charts

struct CategoryBreakdownChart: View {
    let transactions: [Transaction]
    @State private var selectedCategoryName: String?
    
    var body: some View {
        Chart(groupedData, id: \.categoryName) { item in
            SectorMark(
                angle: .value("Amount", item.amount),
                innerRadius: .ratio(0.6),
                angularInset: 2
            )
            .cornerRadius(5)
            .foregroundStyle(Color(hex: item.colorHex))
            .opacity(selectedCategoryName == nil || selectedCategoryName == item.categoryName ? 1.0 : 0.3)
        }
        .frame(height: 220)
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        // Simple hit testing relative to center could be complex for sectors
                        // For simplicity, tapping the chart resets selection or we rely on ChartSelection if available in iOS 17
                        // Fallback: Just let users tap the legend or list if we had one.
                        // Or simplistic toggle:
                        withAnimation {
                            selectedCategoryName = nil
                        }
                    }
            }
        }
        .chartBackground { proxy in
            GeometryReader { geo in
                VStack(spacing: 4) {
                    if let selected = selectedData {
                        Text(selected.categoryName)
                            .font(Theme.Fonts.body(12))
                            .foregroundStyle(Theme.Colors.secondaryText)
                            .lineLimit(1)
                        Text(String(format: "$%.0f", selected.amount))
                            .font(Theme.Fonts.display(24))
                            .foregroundStyle(Theme.Colors.primaryText)
                    } else {
                        Text("Total")
                            .font(Theme.Fonts.body(12))
                            .foregroundStyle(Theme.Colors.secondaryText)
                        Text(String(format: "$%.0f", totalAmount))
                            .font(Theme.Fonts.display(24))
                            .foregroundStyle(Theme.Colors.primaryText)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        // Add chart selection behavior if iOS 17+
        .chartAngleSelection(value: $selectedCategoryName)
    }
    
    private var totalAmount: Double {
        groupedData.reduce(0) { $0 + $1.amount }
    }
    
    private var selectedData: CategoryData? {
        guard let name = selectedCategoryName else { return nil }
        return groupedData.first(where: { $0.categoryName == name })
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
