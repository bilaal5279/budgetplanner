import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Query private var accounts: [Account]
    @Query private var allTransactions: [Transaction]
    
    @State private var csvURL: URL?
    
    @AppStorage("appTheme") private var currentTheme: Theme.AppAppearance = .system
    @AppStorage("appAccent") private var currentAccent: Theme.AppAccent = .mint
    @State private var showResetConfirmation = false
    
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - General
                Section("General") {
                    // Currency
                    NavigationLink(destination: CurrencySelectionView()) {
                        HStack {
                            Image(systemName: "banknote")
                                .foregroundStyle(Theme.Colors.mint)
                                .frame(width: 24)
                            Text("Currency")
                            Spacer()
                            Text(CurrencyManager.shared.currencyCode)
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                    }
                    
                    // Language
                    HStack {
                        Image(systemName: "globe")
                            .foregroundStyle(Theme.Colors.mint)
                            .frame(width: 24)
                        Text("Language")
                        Spacer()
                        Text(Locale.current.language.languageCode?.identifier.uppercased() ?? "EN")
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                }
                
                // MARK: - Categorization
                Section("Categorization") {
                    NavigationLink(destination: CategoriesSettingsView(type: .expense)) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                                .foregroundStyle(Theme.Colors.coral)
                                .frame(width: 24)
                            Text("Expense Categories")
                        }
                    }
                    
                    NavigationLink(destination: CategoriesSettingsView(type: .income)) {
                        HStack {
                            Image(systemName: "tray.and.arrow.down.fill")
                                .foregroundStyle(Theme.Colors.mint)
                                .frame(width: 24)
                            Text("Income Categories")
                        }
                    }
                }
                
                // MARK: - Appearance
                Section("Appearance") {
                    Picker(selection: $currentTheme) {
                        ForEach(Theme.AppAppearance.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "circle.lefthalf.filled")
                                .foregroundStyle(Theme.Colors.mint)
                                .frame(width: 24)
                            Text("Theme")
                        }
                    }
                    
                    Picker(selection: $currentAccent) {
                        ForEach(Theme.AppAccent.allCases) { accent in
                            HStack {
                                Circle()
                                    .fill(accent.color)
                                    .frame(width: 20, height: 20)
                                Text(accent.rawValue)
                            }
                            .tag(accent)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundStyle(Theme.Colors.mint)
                                .frame(width: 24)
                            Text("Accent Color")
                        }
                    }
                }
                
                // MARK: - Widgets
                Section("Widgets") {
                    HStack {
                        Image(systemName: "square.dashed")
                            .foregroundStyle(Theme.Colors.secondaryText)
                            .frame(width: 24)
                        Text("Home Screen Widgets")
                            .foregroundStyle(Theme.Colors.secondaryText)
                        Spacer()
                        Text("Coming Soon")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.Colors.secondaryBackground)
                            .clipShape(Capsule())
                    }
                }
                
                // MARK: - Data
                Section("Data") {
                    if let url = CSVManager.generateCSV(from: allTransactions) {
                        ShareLink(item: url) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(Theme.Colors.mint)
                                    .frame(width: 24)
                                Text("Export to CSV")
                                    .foregroundStyle(Theme.Colors.primaryText)
                            }
                        }
                    }
                    
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                                .frame(width: 24)
                            Text("Delete All Data")
                        }
                    }
                }
                
                // MARK: - Support
                Section("Support") {
                    Link(destination: URL(string: "https://apps.apple.com/app/id6756530207?action=write-review")!) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(.yellow)
                                .frame(width: 24)
                            Text("Rate on App Store")
                                .foregroundStyle(Theme.Colors.primaryText)
                        }
                    }
                    
                    Link(destination: URL(string: "mailto:info@digitalsprout.org")!) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(Theme.Colors.mint)
                                .frame(width: 24)
                            Text("Contact Support")
                                .foregroundStyle(Theme.Colors.primaryText)
                        }
                    }
                    
                    // Placeholder for About Us - can be a simple nav link or text
                    NavigationLink {
                         AboutView()
                    } label: {
                        HStack {
                             Image(systemName: "info.circle")
                                 .foregroundStyle(Theme.Colors.mint)
                                 .frame(width: 24)
                             Text("About Us")
                        }
                    }
                }
                         
                // MARK: - Legal
                Section("Legal") {
                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                         Text("Terms of Service")
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                    
                    Link(destination: URL(string: "https://pocketwealth.app/privacy")!) {
                         Text("Privacy Policy")
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                }
                
                // Version
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("PocketWealth")
                                .font(.headline)
                                .foregroundStyle(Theme.Colors.primaryText)
                            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                                .font(.caption)
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Settings")
            .confirmationDialog("Are you sure?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Delete All Data", role: .destructive) {
                    resetData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All your transactions and categories will be permanently deleted.")
            }
        }
    }
    
    // Minimal Helper functions...
    
    #if DEBUG
    private func seedRandomData() {
        // fetch existing categories and accounts to link
        // We'll just do a quick fetch or assume safe to use Query if available?
        // Query properties are available in View.
        
        guard !categories.isEmpty, !accounts.isEmpty else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        for _ in 0..<50 {
            // Random Date within last 90 days
            let daysBack = Int.random(in: 0...90)
            let date = calendar.date(byAdding: .day, value: -daysBack, to: today)!
            
            // Random Amount 5.00 - 150.00
            let amount = Double.random(in: 5...150)
            
            // Random Type (mostly expense)
            let type: TransactionType = Int.random(in: 0...10) > 2 ? .expense : .income
            
            // Random Category/Account
            let category = type == .expense ? categories.randomElement() : nil
            let account = accounts.randomElement()!
            
            let transaction = Transaction(
                amount: amount,
                date: date,
                type: type,
                note: "Mock Data",
                category: category,
                account: account
            )
            
            // Update balance
            if type == .expense {
                account.balance -= amount
            } else {
                account.balance += amount
            }
            
            modelContext.insert(transaction)
        }
    }
    
    private func resetData() {
        try? modelContext.delete(model: Transaction.self)
        // Reset balances? For now, let's just keep accounts but maybe reset their balance to 0
        for account in accounts {
            account.balance = 0
        }
    }
    #endif
}
