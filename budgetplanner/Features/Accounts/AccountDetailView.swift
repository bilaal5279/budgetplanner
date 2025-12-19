import SwiftUI
import SwiftData

struct AccountDetailView: View {
    @Bindable var account: Account
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // Transactions
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    
    // States
    @State private var showAddMoneySheet = false
    @State private var showEditBalanceAlert = false
    @State private var newBalanceString = ""
    @State private var showEditAccountSheet = false
    @State private var showDeleteAlert = false

    
    var accountTransactions: [Transaction] {
        allTransactions.filter { $0.account == account || $0.transferTargetAccount == account }
    }
    
    var groupedTransactions: [(Date, [Transaction])] {
        let grouped = Dictionary(grouping: accountTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Premium Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: account.colorHex).opacity(0.1))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: account.icon)
                                .font(.system(size: 32))
                                .foregroundStyle(Color(hex: account.colorHex))
                        }
                        
                        VStack(spacing: 4) {
                            Text(account.name)
                                .font(Theme.Fonts.body(16))
                                .foregroundStyle(Theme.Colors.secondaryText)
                            
                            Text(String(format: "$%.2f", account.balance))
                                .font(Theme.Fonts.display(40))
                                .foregroundStyle(Theme.Colors.primaryText)
                        }
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Action Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ActionButton(icon: "plus", title: "Add Money", color: Theme.Colors.mint) {
                            showAddMoneySheet = true
                        }
                        
                        ActionButton(icon: "pencil", title: "Edit Balance", color: Theme.Colors.primaryText) {
                            newBalanceString = String(format: "%.2f", account.balance)
                            showEditBalanceAlert = true
                        }
                        
                        ActionButton(icon: "gearshape.fill", title: "Edit Details", color: Theme.Colors.secondaryText) {
                            showEditAccountSheet = true
                        }
                        
                        ActionButton(icon: account.isArchived ? "tray.and.arrow.up.fill" : "archivebox.fill",
                                     title: account.isArchived ? "Unarchive" : "Archive",
                                     color: account.isArchived ? Theme.Colors.primaryText : Theme.Colors.coral) {
                            withAnimation {
                                account.isArchived.toggle()
                                if account.isArchived {
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Transactions List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("History")
                            .font(Theme.Fonts.display(18))
                            .foregroundStyle(Theme.Colors.primaryText)
                            .padding(.leading, 8)
                        
                        if accountTransactions.isEmpty {
                            ContentUnavailableView("No Transactions", systemImage: "list.bullet.clipboard", description: Text("Transactions associated with this account will appear here."))
                                .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 20) {
                                ForEach(groupedTransactions, id: \.0) { date, transactions in
                                    Section {
                                        VStack(spacing: 12) {
                                            ForEach(transactions) { transaction in
                                                NavigationLink(value: transaction) {
                                                     AccountTransactionRow(transaction: transaction, account: account)
                                                }
                                                // Separator logic handled by row or we move it inside? 
                                                // Actually standard List style separator logic or custom. Keeping custom divider.
                                                if transaction != transactions.last {
                                                    Divider()
                                                        .padding(.leading, 60)
                                                        .opacity(0.3)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(Theme.Colors.secondaryBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                    } header: {
                                        HStack {
                                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                                .font(Theme.Fonts.body(14))
                                                .foregroundStyle(Theme.Colors.secondaryText)
                                                .padding(.leading, 8)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        // Add Money Sheet
        .sheet(isPresented: $showAddMoneySheet) {
            AddTransactionView(preSelectedAccount: account, preSelectedType: .income)
        }
        // Edit Balance Alert
        .alert("Update Balance", isPresented: $showEditBalanceAlert) {
            TextField("Amount", text: $newBalanceString)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if let newBal = Double(newBalanceString) {
                    account.balance = newBal
                }
            }
        } message: {
            Text("Enter the new balance for this account.")
        }
        // Edit Account Sheet
        .sheet(isPresented: $showEditAccountSheet) {
            AddAccountView(accountToEdit: account)
        }
        // Detail Navigation
        .navigationDestination(for: Transaction.self) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }
}

// MARK: - Subcomponents

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(Theme.Fonts.body(12))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Theme.Colors.secondaryBackground)
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct AccountTransactionRow: View {
    let transaction: Transaction
    let account: Account // Context to know if + or -
    
    var isPositive: Bool {
        if transaction.type == .income { return true }
        if transaction.type == .expense { return false }
        // Transfer logic
        if transaction.type == .transfer {
            return transaction.transferTargetAccount == account
        }
        return false
    }
    
    var amountColor: Color {
        isPositive ? Theme.Colors.mint : Theme.Colors.primaryText
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Theme.Colors.background)
                    .frame(width: 44, height: 44)
                
                let iconName = transaction.category?.icon ?? (transaction.type == .transfer ? "arrow.left.arrow.right" : "dollarsign")
                let iconColor = transaction.category.map { Color(hex: $0.colorHex) } ?? Theme.Colors.primaryText
                
                Image(systemName: iconName)
                    .foregroundStyle(iconColor)
                    .font(.system(size: 18))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category?.name ?? transaction.type.rawValue)
                    .font(Theme.Fonts.body(16))
                    .foregroundStyle(Theme.Colors.primaryText)
                
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(Theme.Fonts.body(12))
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
            
            Spacer()
            
            // Amount
            Text((isPositive ? "+" : "-") + String(format: "$%.2f", transaction.amount))
                .font(Theme.Fonts.body(16))
                .foregroundStyle(amountColor)
        }
    }
}
