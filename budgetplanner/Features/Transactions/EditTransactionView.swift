import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Bindable var transaction: Transaction
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Query(sort: \Category.name) private var categories: [Category]
    
    @State private var amountString: String = ""
    @State private var selectedCategory: Category?
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Amount Input
                            VStack(spacing: 8) {
                                Text("Amount")
                                    .font(Theme.Fonts.body(14))
                                    .foregroundStyle(Theme.Colors.secondaryText)
                                
                                HStack(spacing: 4) {
                                    Text("$")
                                        .font(Theme.Fonts.display(40))
                                        .foregroundStyle(Theme.Colors.primaryText)
                                    
                                    TextField("0.00", text: $amountString)
                                        .font(Theme.Fonts.display(40))
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.leading) // Center causing layout issues sometimes
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            .padding(.top, 20)
                            
                            // Details Form
                            VStack(spacing: 20) {
                                // Date Picker
                                DatePicker("Date", selection: $date, displayedComponents: .date)
                                    .font(Theme.Fonts.body(16))
                                
                                Divider()
                                
                                // Category (If applicable)
                                if transaction.type != .transfer && transaction.type != .income {
                                     HStack {
                                         Text("Category")
                                             .font(Theme.Fonts.body(16))
                                         Spacer()
                                         Menu {
                                             ForEach(categories) { category in
                                                 Button {
                                                     selectedCategory = category
                                                 } label: {
                                                     Label(category.name, systemImage: category.icon)
                                                 }
                                             }
                                         } label: {
                                             if let cat = selectedCategory {
                                                HStack {
                                                    Image(systemName: cat.icon)
                                                        .foregroundStyle(Color(hex: cat.colorHex))
                                                    Text(cat.name)
                                                        .foregroundStyle(Theme.Colors.primaryText)
                                                }
                                             } else {
                                                 Text("Select")
                                                     .foregroundStyle(Theme.Colors.secondaryText)
                                             }
                                         }
                                     }
                                     Divider()
                                }
                                
                                // Note
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Note")
                                        .font(Theme.Fonts.body(14))
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                    
                                    TextField("Add a note...", text: $note)
                                        .padding()
                                        .background(Theme.Colors.secondaryBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding()
                            .background(Theme.Colors.background) // Or secondary?
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                        }
                    }
                    
                    // Footer Actions
                    VStack(spacing: 16) {
                        Button {
                            saveChanges()
                        } label: {
                            Text("Save Changes")
                                .font(Theme.Fonts.display(18))
                                .foregroundStyle(Theme.Colors.background)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Theme.Colors.primaryText)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: Theme.Colors.primaryText.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Text("Delete Transaction")
                                .font(Theme.Fonts.body(16))
                                .foregroundStyle(Theme.Colors.coral)
                        }
                    }
                    .padding(24)
                    .background(Theme.Colors.background)
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                // Populate existing data
                amountString = String(format: "%.2f", transaction.amount * 100)
                date = transaction.date
                note = transaction.note
                selectedCategory = transaction.category
            }
            .alert("Delete Transaction", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteTransaction()
                }
            } message: {
                Text("Are you sure? This will adjust your account balance.")
            }
        }
    }
    
    // MARK: - Logic
    
    private func saveChanges() {
        guard let newAmountVal = Double(amountString) else { return }
        let newAmount = newAmountVal / 100
        
        // 1. Revert Old Balance Effect
        revertBalanceEffect(amount: transaction.amount, type: transaction.type, account: transaction.account, target: transaction.transferTargetAccount)
        
        // 2. Update Transaction
        transaction.amount = newAmount
        transaction.date = date
        transaction.note = note
        transaction.category = selectedCategory
        
        // 3. Apply New Balance Effect
        applyBalanceEffect(amount: newAmount, type: transaction.type, account: transaction.account, target: transaction.transferTargetAccount)
        
        dismiss()
    }
    
    private func deleteTransaction() {
        // 1. Revert Balance Effect
        revertBalanceEffect(amount: transaction.amount, type: transaction.type, account: transaction.account, target: transaction.transferTargetAccount)
        
        // 2. Delete
        modelContext.delete(transaction)
        
        dismiss()
    }
    
    private func revertBalanceEffect(amount: Double, type: TransactionType, account: Account?, target: Account?) {
        guard let account = account else { return }
        
        switch type {
        case .expense:
            account.balance += amount // Add back spent money
        case .income:
            account.balance -= amount // Remove earned money
        case .transfer:
            account.balance += amount // Add back to source
            target?.balance -= amount // Remove from target
        }
    }
    
    private func applyBalanceEffect(amount: Double, type: TransactionType, account: Account?, target: Account?) {
        guard let account = account else { return }
        
        switch type {
        case .expense:
            account.balance -= amount
        case .income:
            account.balance += amount
        case .transfer:
            account.balance -= amount
            target?.balance += amount
        }
    }
}
