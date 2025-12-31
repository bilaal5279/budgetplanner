import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Account.sortOrder) private var accounts: [Account]
    
    @State private var amountString: String = ""
    @State private var selectedCategory: Category?
    @State private var selectedType: TransactionType = .expense
    @State private var selectedAccount: Account?
    @State private var targetAccount: Account?
    @State private var didInitialize = false
    
    // Pre-selection params
    var preSelectedAccount: Account?
    var preSelectedType: TransactionType = .expense

    // Sheet States
    @State private var showCategorySheet = false
    @State private var showAccountSheet = false
    @State private var note: String = ""
    @State private var showNoteInput = false
    @State private var showRatingPrompt = false
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header & Type Selector
                VStack(spacing: 8) {
                    Text("Add Transaction")
                        .font(Theme.Fonts.display(16))
                        .foregroundStyle(Theme.Colors.primaryText)
                        .padding(.top, 10)
                    
                    HStack(spacing: 0) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Button {
                                let generator = UISelectionFeedbackGenerator()
                                generator.selectionChanged()
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedType = type
                                    if type == .income {
                                        if let bankCard = accounts.first(where: { $0.name == "Bank Card" }) {
                                            selectedAccount = bankCard
                                        } else {
                                            selectedAccount = accounts.first
                                        }
                                    }
                                }
                            } label: {
                                Text(type.rawValue)
                                    .font(Theme.Fonts.body(13))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(selectedType == type ? Theme.Colors.background : Color.clear)
                                    .foregroundStyle(selectedType == type ? Theme.Colors.primaryText : Theme.Colors.primaryText.opacity(0.5))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(3)
                    .background(Theme.Colors.secondaryBackground)
                    .clipShape(Capsule())
                    .padding(.horizontal, 50)
                }
                .padding(.bottom, 10)
                                
                Spacer(minLength: 20)
                
                // MARK: - Amount Display
                Text(currencyString)
                    .font(Theme.Fonts.display(64)) // Restored size
                    .foregroundStyle(Theme.Colors.primaryText)
                    .contentTransition(.numericText())
                    .scaleEffect(amountString.isEmpty ? 0.9 : 1.0)
                    .minimumScaleFactor(0.5)
                    .animation(.spring(response: 0.3), value: amountString)
                    .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // MARK: - Inputs Section (Bottom Sheet)
                VStack(spacing: 16) {
                    
                    if selectedType == .transfer {
                        // Transfer Layout
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                // Source Account
                                AccountPickerCard(title: "From", selection: $selectedAccount, accounts: accounts)
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(Theme.Colors.secondaryText)
                                
                                // Target Account
                                AccountPickerCard(title: "To", selection: $targetAccount, accounts: accounts)
                            }
                            
                            // Note Button (Transfer)
                            Button {
                                showNoteInput = true
                            } label: {
                                HStack {
                                    Image(systemName: note.isEmpty ? "text.bubble" : "text.bubble.fill")
                                    Text(note.isEmpty ? "Add Note" : "Edit Note")
                                }
                                .font(Theme.Fonts.body(14))
                                .foregroundStyle(note.isEmpty ? Theme.Colors.secondaryText : Theme.Colors.mint)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Theme.Colors.background)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                        
                    } else {
                        // Standard Layout
                        VStack(spacing: 16) {
                            // Account Picker & Note
                            HStack(spacing: 12) {
                                Button {
                                    showAccountSheet = true
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Account")
                                                .font(Theme.Fonts.body(12))
                                                .foregroundStyle(Theme.Colors.secondaryText)
                                            Text(selectedAccount?.name ?? "Select Account")
                                                .font(Theme.Fonts.body(16))
                                                .foregroundStyle(Theme.Colors.primaryText)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Theme.Colors.primaryText)
                                    }
                                    .padding()
                                    .background(Theme.Colors.background)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Theme.Colors.secondaryText.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                
                                // Note Button
                                Button {
                                    showNoteInput = true
                                } label: {
                                    Image(systemName: note.isEmpty ? "text.bubble" : "text.bubble.fill")
                                        .font(.system(size: 20))
                                        .foregroundStyle(note.isEmpty ? Theme.Colors.secondaryText : Theme.Colors.mint)
                                        .frame(width: 50, height: 60) // Match Account Picker approx height
                                        .background(Theme.Colors.background)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Theme.Colors.secondaryText.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    
                    Divider()
                        .background(Theme.Colors.secondaryText.opacity(0.1))
                        .padding(.vertical, 4)
                    
                    // MARK: - Keypad
                    CustomKeypad(input: $amountString)
                        // Allow keypad to be compact if needed via internal logic, but here assume it fits
                    
                    // MARK: - Save Button
                    // MARK: - Save Button
                    Button {
                        handleSave()
                    } label: {
                        Text("Save")
                            .font(Theme.Fonts.display(18))
                            .foregroundStyle(Theme.Colors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                Theme.Colors.primaryText
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .disabled(selectedType == .transfer && selectedAccount == targetAccount)
                    .opacity(selectedType == .transfer && selectedAccount == targetAccount ? 0.6 : 1.0)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12)
                }
                .padding(.top, 20)
                .background(
                    Theme.Colors.secondaryBackground
                        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
            // Removed padding(.bottom, 80) causing compression
            // MainTabView handles safe area inset

        }
        .sheet(isPresented: $showCategorySheet) {
            CategorySelectionSheet(
                color: typeColor,
                onSelect: { category in
                    selectedCategory = category
                    saveTransaction(with: category)
                }
            )
        }
        .sheet(isPresented: $showAccountSheet) {
            AccountSelectionSheet(selectedAccount: $selectedAccount)
        }
        .alert("Add Note", isPresented: $showNoteInput) {
            TextField("Note", text: $note)
            Button("Done") {}
            Button("Cancel", role: .cancel) {}
        }
        .alert("How is your experience?", isPresented: $showRatingPrompt) {
            Button("It's Great! 😍") {
                RatingManager.shared.openAppStoreReview()
            }
            Button("Could be better", role: .cancel) {
                // Just dismiss
            }
        } message: {
            Text("We'd love to hear your feedback on the App Store!")
        }
        .onAppear {
            if !didInitialize {
                if let account = preSelectedAccount {
                    selectedAccount = account
                } else {
                    selectedAccount = accounts.first
                }
                
                selectedType = preSelectedType
                
                selectedCategory = categories.first
                
                // Ensure target is different if possible
                if accounts.count > 1 {
                    targetAccount = accounts[1]
                } else {
                    targetAccount = accounts.first
                }
                didInitialize = true
            }
        }
    }
    
    // MARK: - Helpers
    
    private var currencyString: String {
        let symbol = CurrencyManager.shared.getSymbol(for: CurrencyManager.shared.currencyCode)
        if amountString.isEmpty { return "\(symbol)0" }
        return symbol + amountString
    }
    
    private var typeColor: Color {
        switch selectedType {
        case .expense: return Theme.Colors.coral
        case .income: return Theme.Colors.mint
        case .transfer: return Theme.Colors.primaryText
        }
    }
    
    private func handleSave() {
        guard let amountVal = Double(amountString), amountVal > 0 else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        // Prevent transfer to same account
        if selectedType == .transfer, selectedAccount == targetAccount {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        if selectedType == .expense {
            showCategorySheet = true
        } else {
            saveTransaction()
        }
    }

    private func saveTransaction(with category: Category? = nil) {
        guard let amountVal = Double(amountString), amountVal > 0 else { return }
        let finalAmount = amountVal
        
        // Use provided category or existing state (for income/transfer)
        let finalCategory = category ?? selectedCategory
        
        let transaction = Transaction(
            amount: finalAmount,
            date: Date(),
            type: selectedType,
            note: note, // Pass the note
            category: selectedType == .transfer ? nil : finalCategory,
            account: selectedAccount,
            transferTargetAccount: targetAccount
        )
        
        // Update Account Balances
        if let account = selectedAccount {
            if selectedType == .expense {
                account.balance -= finalAmount
            } else if selectedType == .income {
                account.balance += finalAmount
            } else if selectedType == .transfer {
                account.balance -= finalAmount
                if let target = targetAccount {
                    target.balance += finalAmount
                }
            }
        }
        
        modelContext.insert(transaction)
        
        // Success Feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        amountString = ""
        note = "" // Reset note
        
        // Check for First Transaction Rating Prompt
        if RatingManager.shared.shouldShowFirstTransactionPrompt() {
            showRatingPrompt = true
        }
    }
}

// MARK: - Subcomponents

struct AccountPickerCard: View {
    let title: String
    @Binding var selection: Account?
    let accounts: [Account]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Theme.Fonts.body(12))
                .foregroundStyle(Theme.Colors.secondaryText)
                .padding(.leading, 4)
            
            Menu {
                ForEach(accounts) { account in
                    Button(action: { selection = account }) {
                        Label(account.name, systemImage: account.icon)
                    }
                }
            } label: {
                HStack {
                    if let account = selection {
                        Image(systemName: account.icon)
                            .foregroundStyle(Color(hex: account.colorHex))
                        Text(account.name)
                            .foregroundStyle(Theme.Colors.primaryText)
                            .lineLimit(1)
                    } else {
                        Text("Select")
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
                .padding()
                .frame(height: 50)
                .background(Theme.Colors.secondaryBackground) // Inverted context? No, just keep standard
                // Wait, if parent is secondaryBackground, this needs contrast?
                // Using .background(Theme.Colors.background) for differentiation inside the sheet
                .background(Theme.Colors.background)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.Colors.secondaryText.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}
