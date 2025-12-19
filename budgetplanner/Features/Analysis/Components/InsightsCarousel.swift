import SwiftUI

struct InsightsCarousel: View {
    let income: Double
    let expense: Double
    let net: Double
    // let topCategory: (name: String, amount: Double, icon: String, color: String)? // Removed
    let avgPerDay: Double
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Card 1: Net Balance Health
                InsightCard(
                    title: "Cash Flow",
                    icon: "arrow.triangle.2.circlepath",
                    color: Theme.Colors.mint
                ) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net Balance")
                            .font(.caption)
                            .foregroundStyle(Theme.Colors.secondaryText)
                        
                        Text(net.formatted(.currency(code: "USD")))
                            .font(.title3.bold())
                            .foregroundStyle(net >= 0 ? Theme.Colors.primaryText : Theme.Colors.coral)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8) // Adjusted for consistency
                        
                        // Mini Bar Visualization
                        HStack(spacing: 4) {
                            // Simple bar concept
                            Capsule()
                                .fill(Theme.Colors.mint)
                                .frame(width: 40, height: 4)
                            Capsule()
                                .fill(Theme.Colors.coral)
                                .frame(width: 30, height: 4)
                        }
                        .padding(.top, 4)
                    }
                }
                
                // Card 2: Spending Pace
                InsightCard(
                    title: "Pace",
                    icon: "speedometer",
                    color: Theme.Colors.coral
                ) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Avg / Day")
                            .font(.caption)
                            .foregroundStyle(Theme.Colors.secondaryText)
                        
                        Text(avgPerDay.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                            .font(.title3.bold())
                            .foregroundStyle(Theme.Colors.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8) // Match the other card
                        
                        Text("For this period")
                            .font(.caption2)
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                }
            }
            .padding(.horizontal)
        }
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
                
                Spacer()
                
//                Image(systemName: "chevron.right")
//                    .font(.caption2)
//                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            
            content
        }
        .padding(14)
        .frame(width: 160, height: 120, alignment: .topLeading) // Increased width
        .background(Theme.Colors.secondaryBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Theme.Colors.secondaryText.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
