import SwiftUI

struct MoneyFlowCard: View {
    let income: Double
    let expense: Double
    
    var net: Double {
        income - expense
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Money Flow")
                .font(.headline)
                .foregroundStyle(Theme.Colors.primaryText)
            
            VStack(spacing: 0) {
                // Income Row
                HStack {
                    Circle()
                        .fill(Theme.Colors.mint.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "arrow.down")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.Colors.mint)
                        }
                    
                    Text("Income")
                        .font(Theme.Fonts.body(16))
                        .foregroundStyle(Theme.Colors.secondaryText)
                    
                    Spacer()
                    
                    Text(income.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                        .font(Theme.Fonts.body(16).weight(.semibold))
                        .foregroundStyle(Theme.Colors.primaryText)
                }
                .padding(.vertical, 12)
                
                Divider()
                    .padding(.leading, 40)
                
                // Expense Row
                HStack {
                    Circle()
                        .fill(Theme.Colors.coral.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.Colors.coral)
                        }
                    
                    Text("Expenses")
                        .font(Theme.Fonts.body(16))
                        .foregroundStyle(Theme.Colors.secondaryText)
                    
                    Spacer()
                    
                    Text(expense.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                        .font(Theme.Fonts.body(16).weight(.semibold))
                        .foregroundStyle(Theme.Colors.primaryText)
                }
                .padding(.vertical, 12)
                
                Divider()
                
                // Net Balance
                HStack {
                    Text("Net Balance")
                        .font(Theme.Fonts.body(16).weight(.medium))
                        .foregroundStyle(Theme.Colors.primaryText)
                    
                    Spacer()
                    
                    Text(net.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                        .font(Theme.Fonts.display(18))
                        .foregroundStyle(Theme.Colors.primaryText)
                }
                .padding(.top, 16)
                .padding(.bottom, 4)
            }
            .padding(16)
            .background(Theme.Colors.secondaryBackground) // Light gray/blue box
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
