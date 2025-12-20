import SwiftUI

struct InsightsCarousel: View {
    let income: Double
    let expense: Double
    let net: Double
    // let topCategory: (name: String, amount: Double, icon: String, color: String)? // Removed
    let avgPerDay: Double
    let dailySubtitle: String
    
    var body: some View {
        // Grid Layout instead of ScrollView
        HStack(spacing: 12) {
            // Card 1: Net Balance Health
            InsightCard(
                title: "Net Balance",
                icon: "arrow.triangle.2.circlepath",
                color: Theme.Colors.mint
            ) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profit/Loss")
                        .font(.caption)
                        .foregroundStyle(Theme.Colors.secondaryText)
                    
                    Text(net.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                        .font(.title3.bold())
                        .foregroundStyle(net >= 0 ? Theme.Colors.primaryText : Theme.Colors.coral)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    // Mini Bar Visualization
                    HStack(spacing: 4) {
                        Capsule()
                            .fill(Theme.Colors.mint)
                            .frame(maxWidth: .infinity, maxHeight: 4) // Flex width
                        Capsule()
                            .fill(Theme.Colors.coral)
                            .frame(maxWidth: percentageOfExpense, maxHeight: 4) // Dynamic width based on ratio
                    }
                    .padding(.top, 4)
                }
            }
            
            // Card 2: Spending/Income Daily Average
            InsightCard(
                title: "Daily Average",
                icon: "speedometer",
                color: Theme.Colors.coral
            ) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dailySubtitle)
                        .font(.caption)
                        .foregroundStyle(Theme.Colors.secondaryText)
                    
                    Text(avgPerDay.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                        .font(.title3.bold())
                        .foregroundStyle(Theme.Colors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text("For this period")
                        .font(.caption2)
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // Helper for visual bar
    var percentageOfExpense: CGFloat {
        guard income > 0 else { return 50 } // Default
        let ratio = expense / income
        return CGFloat(min(max(ratio * 50, 10), 100))
    }

}

struct InsightCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 28, height: 28)
                    .overlay {
                        Image(systemName: icon)
                            .font(.caption.bold())
                            .foregroundStyle(color)
                    }
                
                Text(title)
                    .font(Theme.Fonts.body(14).weight(.medium))
                    .foregroundStyle(Theme.Colors.primaryText)
                
                Spacer()
            }
            
            content
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading) // Flex width
        .background(Theme.Colors.secondaryBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.Colors.secondaryText.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
