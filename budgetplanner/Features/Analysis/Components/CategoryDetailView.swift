import SwiftUI

struct CategoryDetailView: View {
    let categoryName: String
    let transactions: [Transaction]
    
    var total: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Circle()
                        .fill(Theme.Colors.secondaryBackground)
                        .frame(width: 60, height: 60)
                        .overlay {
                            // Extract icon from first transaction if possible, or generic
                            let icon = transactions.first?.category?.icon ?? "tag.fill"
                            let colorHex = transactions.first?.category?.colorHex ?? "808080"
                            Image(systemName: icon)
                                .font(.title)
                                .foregroundStyle(Color(hex: colorHex))
                        }
                    
                    Text(categoryName)
                        .font(.headline)
                        .foregroundStyle(Theme.Colors.primaryText)
                    
                    Text(total.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                        .font(Theme.Fonts.display(32))
                        .foregroundStyle(Theme.Colors.primaryText)
                }
                .padding(.top, 20)
                
                // Transactions List
                LazyVStack(spacing: 0) {
                    ForEach(transactions) { transaction in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(transaction.note.isEmpty ? "Payment" : transaction.note)
                                    .font(Theme.Fonts.body(16))
                                    .foregroundStyle(Theme.Colors.primaryText)
                                
                                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }
                            
                            Spacer()
                            
                            Text(transaction.amount.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                            .font(.body.weight(.semibold))
                            .foregroundStyle(transaction.type == .income ? Theme.Colors.mint : Theme.Colors.primaryText)
                        }
                        .padding()
                        
                        Divider()
                            .padding(.leading)
                    }
                }
                .background(Theme.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
