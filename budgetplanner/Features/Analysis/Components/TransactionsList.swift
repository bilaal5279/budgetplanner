import SwiftUI

struct TransactionsList: View {
    let transactions: [Transaction]
    
    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(transactions) { transaction in
                VStack(spacing: 0) {
                    HStack(spacing: 16) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color(hex: transaction.category?.colorHex ?? "00C48C").opacity(0.1))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: transaction.category?.icon ?? "tray")
                                .font(.system(size: 18))
                                .foregroundStyle(Color(hex: transaction.category?.colorHex ?? "00C48C"))
                        }
                        
                        // Details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(transaction.note.isEmpty ? (transaction.category?.name ?? "Transaction") : transaction.note)
                                .font(Theme.Fonts.body(16))
                                .foregroundStyle(Theme.Colors.primaryText)
                                .lineLimit(1)
                            
                            Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                .font(Theme.Fonts.body(12))
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                        
                        Spacer()
                        
                        // Amount
                        Text((transaction.type == .expense ? "- " : "+ ") + transaction.amount.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                            .font(Theme.Fonts.display(16))
                            .foregroundStyle(transaction.type == .expense ? Theme.Colors.primaryText : Theme.Colors.mint)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    
                    // Separator except for last
                    if transaction.id != transactions.last?.id {
                        Divider()
                            .padding(.leading, 80)
                    }
                }
            }
        }
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
    }
}
