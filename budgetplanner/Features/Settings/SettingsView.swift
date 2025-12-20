import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Query private var accounts: [Account]
    @Query private var allTransactions: [Transaction]
    
    @Query private var preferences: [AppPreferences]
    
    // Direct access for immediate UI updates
    @AppStorage("appTheme") private var currentTheme: Theme.AppAppearance = .system
    @AppStorage("appAccent") private var currentAccent: Theme.AppAccent = .mint
    
    // Derived bindings to update the Model
    private var themeBinding: Binding<Theme.AppAppearance> {
        Binding(
            get: {
                // Prefer local storage for speed, or Model? 
                // Let's stick to the current logic: Model is source of truth for "settings page state", 
                // but we default to AppStorage if Model missing.
                if let first = preferences.first, let theme = Theme.AppAppearance(rawValue: first.themeRawValue) {
                    return theme
                }
                return currentTheme
            },
            set: { newValue in
                // 1. Update Local Storage (Triggers App UI update immediately)
                currentTheme = newValue
                
                // 2. Update Cloud Model
                if let first = preferences.first {
                    first.themeRawValue = newValue.rawValue
                } else {
                    let newPref = AppPreferences(themeRawValue: newValue.rawValue, accentRawValue: currentAccent.rawValue)
                    modelContext.insert(newPref)
                }
            }
        )
    }
    
    private var accentBinding: Binding<Theme.AppAccent> {
        Binding(
            get: {
                if let first = preferences.first, let accent = Theme.AppAccent(rawValue: first.accentRawValue) {
                    return accent
                }
                return currentAccent
            },
            set: { newValue in
                // 1. Update Local Storage
                currentAccent = newValue
                
                // 2. Update Cloud Model
                 if let first = preferences.first {
                    first.accentRawValue = newValue.rawValue
                } else {
                    let newPref = AppPreferences(themeRawValue: currentTheme.rawValue, accentRawValue: newValue.rawValue)
                    modelContext.insert(newPref)
                }
            }
        )
    }
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @AppStorage("useFaceID") private var useFaceID: Bool = false
    
    @State private var showExportSheet = false
    @State private var showResetConfirmation = false
    @State private var showPaywall = false
    @State private var isLoading = false
    @State private var restoreResult: String?
    
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Premium Status
                Section {
                    if subscriptionManager.isPremium {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(Theme.Colors.mint)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Pro Member")
                                    .font(.headline)
                                    .foregroundStyle(Theme.Colors.primaryText)
                                Text("All features unlocked")
                                    .font(.caption)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }
                        }
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Theme.Colors.mint.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "crown.fill")
                                        .foregroundStyle(Theme.Colors.mint)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Upgrade to Pro")
                                        .font(.headline)
                                        .foregroundStyle(Theme.Colors.primaryText)
                                    Text("Unlimited accounts, categories & more")
                                        .font(.caption)
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }
                        }
                    }
                }
                
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
                    
                    // Face ID (Premium)
                    // Face ID (Premium)
                    NavigationLink(destination: AppLockSettingsView(subscriptionManager: subscriptionManager, showPaywall: $showPaywall)) {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundStyle(Theme.Colors.mint)
                                .frame(width: 24)
                            Text("App Lock")
                            Spacer()
                            if !subscriptionManager.isPremium {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            } else {
                                Text(useFaceID ? "On" : "Off")
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }
                        }
                    }
                }
                
                // MARK: - Categorization
                Section("Categorization") {
                    NavigationLink(destination: CategoriesSettingsView(type: .expense)) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                                .foregroundStyle(Theme.Colors.mint)
                                .frame(width: 24)
                            Text("Expense Categories")
                        }
                    }
                    
                    NavigationLink(destination: AccountsSettingsView()) {
                        HStack {
                            Image(systemName: "building.columns.fill")
                                .foregroundStyle(Theme.Colors.mint)
                                .frame(width: 24)
                            Text("Accounts")
                        }
                    }
                }
                
                // MARK: - Appearance
                Section("Appearance") {
                    Picker(selection: themeBinding) {
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
                    
                    Picker(selection: accentBinding) {
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
                // MARK: - Data
                Section("Data") {
                    Button {
                        if subscriptionManager.isPremium {
                            showExportSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                         HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(Theme.Colors.mint)
                                .frame(width: 24)
                            Text("Export to CSV")
                                .foregroundStyle(Theme.Colors.primaryText)
                            
                            if !subscriptionManager.isPremium {
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Theme.Colors.secondaryText)
                                    .font(.caption)
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
                    
                    if !subscriptionManager.isPremium {
                        Button("Restore Purchases") {
                            restorePurchases()
                        }
                        .disabled(isLoading)
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
                    Link(destination: URL(string: "https://digitalsprout.org/pocketwealth/terms-of-service")!) {
                         Text("Terms of Service")
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                    
                    Link(destination: URL(string: "https://digitalsprout.org/pocketwealth/privacy-policy")!) {
                         Text("Privacy Policy")
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                }
                
                #if DEBUG
                Section("Developer") {
                    Button("Reset Onboarding") {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                        // Optional: Quit app or show alert
                    }
                    
                    Button("Add Mock Data") {
                        seedRandomData()
                    }
                }
                #endif
                
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
            .sheet(isPresented: $showExportSheet) {
                ExportOptionsView(allTransactions: allTransactions)
            }
            .fullScreenCover(isPresented: $showPaywall) {
                OnboardingPaywallView(isCompleted: $showPaywall)
            }
            .alert(isPresented: Binding<Bool>(
                get: { restoreResult != nil },
                set: { if !$0 { restoreResult = nil } }
            )) {
                Alert(title: Text("Restore Purchase"), message: Text(restoreResult ?? ""), dismissButton: .default(Text("OK")))
            }
            // If subscription changes to true, we might want to auto-dismiss paywall? 
            // The paywall view handles its own dismissal via `isCompleted` binding.
        }
    }
    
    private func restorePurchases() {
        isLoading = true
        subscriptionManager.restorePurchases { success in
            isLoading = false
            restoreResult = success ? "Purchases restored successfully!" : "No purchases found to restore."
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
    #endif
    
    private func resetData() {
        do {
            // 1. Delete all content
            try modelContext.delete(model: Transaction.self)
            try modelContext.delete(model: Account.self)
            try modelContext.delete(model: Category.self)
            
            // 2. Restore Default Categories
            // 2. Restore Default Categories
            let defaultCategories = [
                Category(name: "Food", icon: "fork.knife", colorHex: "FF6B6B", isCustom: false),
                Category(name: "Transport", icon: "car.fill", colorHex: "54A0FF", isCustom: false),
                Category(name: "Shopping", icon: "cart.fill", colorHex: "F368E0", isCustom: false),
                Category(name: "Entertainment", icon: "tv.fill", colorHex: "A3CB38", isCustom: false)
            ]
            defaultCategories.forEach { modelContext.insert($0) }
            
            // 3. Restore Default Accounts
            let defaultAccounts = [
                Account(name: "Bank Card", balance: 0.0, icon: "creditcard.fill", colorHex: "54A0FF", sortOrder: 0),
                Account(name: "Cash", balance: 0.0, icon: "banknote.fill", colorHex: "2ECC71", sortOrder: 1)
            ]
            defaultAccounts.forEach { modelContext.insert($0) }
            
        } catch {
            print("Failed to reset data: \(error)")
        }
    }
}
