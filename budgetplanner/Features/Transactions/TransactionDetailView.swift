import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Bindable var transaction: Transaction
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // States
    @State private var showEditAmountSheet = false
    @State private var showCategorySheet = false
    @State private var showDeleteAlert = false
    @State private var newAmountString = ""
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Premium Header
                ZStack {
                    // Dynamic background
                    LinearGradient(
                        colors: [
                            (transaction.category.map { Color(hex: $0.colorHex) } ?? Theme.Colors.primaryText).opacity(0.1),
                             Theme.Colors.background
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 24) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Theme.Colors.background)
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                            
                            let iconName = transaction.category?.icon ?? (transaction.type == .transfer ? "arrow.left.arrow.right" : "dollarsign")
                            let iconColor = transaction.category.map { Color(hex: $0.colorHex) } ?? Theme.Colors.primaryText
                            
                            Image(systemName: iconName)
                                .font(.system(size: 32))
                                .foregroundStyle(iconColor)
                        }
                        
                        // Amount
                        Text(String(format: "$%.2f", transaction.amount))
                            .font(Theme.Fonts.display(48))
                            .foregroundStyle(Theme.Colors.primaryText)
                        
                        // Date
                        Text(transaction.date.formatted(date: .long, time: .shortened))
                            .font(Theme.Fonts.body(16))
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                }
                
                // MARK: - Actions List
                ScrollView {
                    VStack(spacing: 16) {
                        
                        // Info Card
                        VStack(spacing: 16) {
                            DetailRow(label: "Type", value: transaction.type.rawValue.capitalized)
                            Divider()
                            DetailRow(label: "Account", value: transaction.account?.name ?? "Unknown")
                            if !transaction.note.isEmpty {
                                Divider()
                                DetailRow(label: "Note", value: transaction.note)
                            }
                        }
                        .padding()
                        .background(Theme.Colors.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        
                        Text("Actions")
                            .font(Theme.Fonts.body(14))
                            .foregroundStyle(Theme.Colors.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                            .padding(.top, 16)
                        
                        // Edit Buttons
                        VStack(spacing: 12) {
                            Button {
                                newAmountString = String(format: "%.2f", transaction.amount * 100)
                                showEditAmountSheet = true
                            } label: {
                                ActionRow(icon: "pencil", title: "Edit Amount", color: Theme.Colors.primaryText)
                            }
                            
                            if transaction.type == .expense {
                                Button {
                                    showCategorySheet = true
                                } label: {
                                    ActionRow(icon: "tag.fill", title: "Change Category", color: Theme.Colors.primaryText)
                                }
                            }
                            
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                ActionRow(icon: "trash", title: "Delete Transaction", color: Theme.Colors.coral)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("Transaction Details")
        .navigationBarTitleDisplayMode(.inline)
        // Edit Amount Sheet
        .alert("Edit Amount", isPresented: $showEditAmountSheet) {
            TextField("Amount", text: $newAmountString)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if let amountVal = Double(newAmountString) {
                    saveNewAmount(amountVal / 100)
                }
            }
        } message: {
            Text("Enter the new amount.")
        }
        // Category Sheet
        .sheet(isPresented: $showCategorySheet) {
             CategorySelectionSheet(color: Theme.Colors.coral) { newCategory in
                 transaction.category = newCategory
             }
        }
        // Delete Alert
        .alert("Delete Transaction", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTransaction()
            }
        }
    }
    
    // MARK: - Logic Helpers
    private func saveNewAmount(_ newAmount: Double) {
        // 1. Revert Old
        revertBalanceEffect(amount: transaction.amount, type: transaction.type, account: transaction.account, target: transaction.transferTargetAccount)
        
        // 2. Set New
        transaction.amount = newAmount
        
        // 3. Apply New
        applyBalanceEffect(amount: newAmount, type: transaction.type, account: transaction.account, target: transaction.transferTargetAccount)
    }
    
    private func deleteTransaction() {
        revertBalanceEffect(amount: transaction.amount, type: transaction.type, account: transaction.account, target: transaction.transferTargetAccount)
        modelContext.delete(transaction)
        dismiss()
    }
    
    // Shared Logic (Duplicated from EditTransactionView for safety/speed)
    private func revertBalanceEffect(amount: Double, type: TransactionType, account: Account?, target: Account?) {
        guard let account = account else { return }
        switch type {
        case .expense: account.balance += amount
        case .income: account.balance -= amount
        case .transfer:
            account.balance += amount
            target?.balance -= amount
        }
    }
    
    private func applyBalanceEffect(amount: Double, type: TransactionType, account: Account?, target: Account?) {
         guard let account = account else { return }
         switch type {
         case .expense: account.balance -= amount
         case .income: account.balance += amount
         case .transfer:
             account.balance -= amount
             target?.balance += amount
         }
     }
}

// MARK: - Subviews
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Theme.Fonts.body(16))
                .foregroundStyle(Theme.Colors.secondaryText)
            Spacer()
            Text(value)
                .font(Theme.Fonts.body(16))
                .foregroundStyle(Theme.Colors.primaryText)
        }
    }
}

struct ActionRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(color)
                .frame(width: 32)
            
            Text(title)
                .font(Theme.Fonts.body(16))
                .foregroundStyle(color)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundStyle(Theme.Colors.secondaryText)
        }
        .padding()
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
