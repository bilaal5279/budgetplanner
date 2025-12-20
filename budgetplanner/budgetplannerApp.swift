//
//  budgetplannerApp.swift
//  budgetplanner
//
//  Created by Bilaal Ishtiaq on 17/12/2025.
//

import SwiftUI
import SwiftData

@main
struct budgetplannerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Budget.self,
            Account.self,
            AppPreferences.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Seed Data
            let context = container.mainContext
            
            // 1. Seed Categories
            let categoryDescriptor = FetchDescriptor<Category>()
            let existingCategories = try? context.fetch(categoryDescriptor)
            
            if existingCategories?.isEmpty ?? true {
                let defaultCategories = [
                    Category(name: "Food", icon: "fork.knife", colorHex: "FF6B6B"),
                    Category(name: "Transport", icon: "car.fill", colorHex: "54A0FF"),
                    Category(name: "Shopping", icon: "cart.fill", colorHex: "F368E0"),
                    Category(name: "Entertainment", icon: "tv.fill", colorHex: "A3CB38")
                ]
                defaultCategories.forEach { context.insert($0) }
            }
            
            // 2. Seed Accounts
            let accountDescriptor = FetchDescriptor<Account>()
            let existingAccounts = try? context.fetch(accountDescriptor)
            
            if existingAccounts?.isEmpty ?? true {
                let defaultAccounts = [
                    Account(name: "Bank Card", balance: 0.0, icon: "creditcard.fill", colorHex: "54A0FF", sortOrder: 0),
                    Account(name: "Cash", balance: 0.0, icon: "banknote.fill", colorHex: "2ECC71", sortOrder: 1)
                ]
                defaultAccounts.forEach { context.insert($0) }
            }
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("appTheme") private var currentTheme: Theme.AppAppearance = .system
    @AppStorage("appAccent") private var currentAccent: Theme.AppAccent = .mint

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .preferredColorScheme(colorScheme)
                    .id(currentAccent) // Force redraw when accent changes
                
                ThemeSyncManager()
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private var colorScheme: ColorScheme? {
        switch currentTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
