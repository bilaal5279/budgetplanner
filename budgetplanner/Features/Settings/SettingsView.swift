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
    
    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: $currentTheme) {
                        ForEach(Theme.AppAppearance.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    Picker("Accent Color", selection: $currentAccent) {
                        ForEach(Theme.AppAccent.allCases) { accent in
                            HStack {
                                Circle()
                                    .fill(accent.color)
                                    .frame(width: 20, height: 20)
                                Text(accent.rawValue)
                            }
                            .tag(accent)
                        }
                    }
                }
                
                Section("Data") {
                    if let url = CSVManager.generateCSV(from: allTransactions) {
                        ShareLink(item: url) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export to CSV")
                            }
                            .foregroundStyle(Theme.Colors.primaryText)
                        }
                    }
                }
                
                Section("Support") {
                    Link(destination: URL(string: "https://apps.apple.com/app/id6756530207?action=write-review")!) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Theme.Colors.mint)
                            Text("Rate Us")
                                .foregroundStyle(Theme.Colors.primaryText)
                        }
                    }
                    
                    ShareLink(item: URL(string: "https://apps.apple.com/app/id6756530207")!) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(Theme.Colors.mint)
                            Text("Share App")
                                .foregroundStyle(Theme.Colors.primaryText)
                        }
                    }
                    
                    Link(destination: URL(string: "mailto:support@pocketwealth.app")!) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(Theme.Colors.mint)
                            Text("Contact Us")
                                .foregroundStyle(Theme.Colors.primaryText)
                        }
                    }
                }
                
                Section("Legal") {
                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        Text("Terms of Service")
                            .foregroundStyle(Theme.Colors.primaryText)
                    }
                    
                    Link(destination: URL(string: "https://pocketwealth.app/privacy")!) {
                        Text("Privacy Policy")
                            .foregroundStyle(Theme.Colors.primaryText)
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                }
                
                #if DEBUG
                Section("Developer") {
                    Button {
                        seedRandomData()
                    } label: {
                        Text("Seed 50 Transactions")
                            .foregroundStyle(Theme.Colors.mint)
                    }
                    
                    Button(role: .destructive) {
                        resetData()
                    } label: {
                        Text("Reset All Data")
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
        }
    }
    
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
