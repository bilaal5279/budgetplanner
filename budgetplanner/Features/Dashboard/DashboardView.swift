import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Wallet")
                        .font(Theme.Fonts.display(24))
                        .foregroundStyle(Theme.Colors.primaryText)
                    Spacer()
                    Image(systemName: "bell.badge")
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
                .padding()
                
                // Balance Card
                VStack(spacing: 8) {
                    Text("Total Balance")
                        .font(Theme.Fonts.body(14))
                        .foregroundStyle(Theme.Colors.secondaryText)
                    
                    Text(formatCurrency(calculateBalance()))
                        .font(Theme.Fonts.display(40))
                        .foregroundStyle(Theme.Colors.primaryText)
                }
                .padding(.vertical, 20)
                
                // Transactions List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(groupedTransactions(), id: \.date) { section in
                            Section {
                                ForEach(section.transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            } header: {
                                HStack {
                                    Text(formatDate(section.date))
                                        .font(Theme.Fonts.body(14))
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top, 10)
                            }
                        }
                    }
                    .padding(.bottom, 100) // Spacer for TabBar
                }
            }
        }
    }
    
    private func calculateBalance() -> Double {
        transactions.reduce(0) { result, transaction in
            return result + (transaction.type == .income ? transaction.amount : -transaction.amount)
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        return value.formatted(.currency(code: CurrencyManager.shared.currencyCode))
    }
    
    private func groupedTransactions() -> [(date: Date, transactions: [Transaction])] {
        let grouped = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        return grouped.sorted { $0.key > $1.key }.map { (date: $0.key, transactions: $0.value) }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: transaction.category?.colorHex ?? "808080").opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transaction.category?.icon ?? "questionmark")
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: transaction.category?.colorHex ?? "808080"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category?.name ?? "Uncategorized")
                    .font(Theme.Fonts.body(16))
                    .foregroundStyle(Theme.Colors.primaryText)
                
                Text(transaction.date.formatted(date: .omitted, time: .shortened))
                    .font(Theme.Fonts.body(12))
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            
            Spacer()
            
            Text((transaction.type == .expense ? "-" : "+") + transaction.amount.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                .font(Theme.Fonts.display(16))
                .foregroundStyle(transaction.type == .expense ? Theme.Colors.primaryText : Theme.Colors.mint)
        }
        .padding()
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
