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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        SubscriptionManager.shared.configure()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Category.self,
            Budget.self,
            Account.self,
            AppPreferences.self,
            BudgetHistory.self
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
                    Category(name: "Food", icon: "fork.knife", colorHex: "FF6B6B", isCustom: false),
                    Category(name: "Transport", icon: "car.fill", colorHex: "54A0FF", isCustom: false),
                    Category(name: "Shopping", icon: "cart.fill", colorHex: "F368E0", isCustom: false),
                    Category(name: "Entertainment", icon: "tv.fill", colorHex: "A3CB38", isCustom: false)
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

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var biometricManager = BiometricManager.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedOnboarding {
                    MainTabView()
                        .preferredColorScheme(colorScheme)
                        .id(currentAccent) // Force redraw when accent changes
                        .transition(.opacity)
                } else {
                    OnboardingContainerView(isCompleted: $hasCompletedOnboarding)
                        .preferredColorScheme(colorScheme)
                        .transition(.opacity)
                }
                
                ThemeSyncManager()
                
                // Content Lock Overlay
                if biometricManager.isLocked {
                    LockedView()
                        .transition(.opacity)
                        .zIndex(999)
                }
            }
            .background(DataDeduplicator()) // Reactive deduplication
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background {
                    biometricManager.applicationDidEnterBackground()
                } else if newPhase == .active {
                    biometricManager.checkLockRequirement()
                    // Deduplication is now handled effectively by DataDeduplicator's onChange
                }
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

// MARK: - Reactive Deduplicator
struct DataDeduplicator: View {
    @Environment(\.modelContext) private var context
    @Query private var categories: [Category]
    @Query private var accounts: [Account]
    
    var body: some View {
        EmptyView()
            .onChange(of: categories) { _, _ in
                deduplicate()
            }
            .onChange(of: accounts) { _, _ in
                deduplicate()
            }
    }
    
    private func deduplicate() {
        do {
            // 1. Deduplicate Categories (Target specific default names)
            let defaultNames = ["Food", "Transport", "Shopping", "Entertainment"]
            let categoryDescriptor = FetchDescriptor<Category>(predicate: #Predicate { defaultNames.contains($0.name) })
            let categories = try context.fetch(categoryDescriptor)
            
            let groupedCategories = Dictionary(grouping: categories, by: { $0.name })
            
            for (_, duplicates) in groupedCategories where duplicates.count > 1 {
                let sorted = duplicates.sorted { (a, b) in
                    return (a.isCustom ? 1 : 0) < (b.isCustom ? 1 : 0)
                }
                
                let winner = sorted.first!
                let losers = sorted.dropFirst()
                
                if winner.isCustom { winner.isCustom = false }
                
                for item in losers {
                    context.delete(item)
                }
            }
            
            // 2. Deduplicate Accounts (Specific Names)
            let accountDescriptor = FetchDescriptor<Account>()
            let accounts = try context.fetch(accountDescriptor)
            
            let targetAccountNames = ["Bank Card", "Cash"]
            let interestingAccounts = accounts.filter { targetAccountNames.contains($0.name) }
            
            let groupedAccounts = Dictionary(grouping: interestingAccounts, by: { $0.name })
            
            for (_, duplicates) in groupedAccounts where duplicates.count > 1 {
                let toDelete = duplicates.dropFirst()
                for item in toDelete {
                    context.delete(item)
                }
            }
            
            try context.save()
            
        } catch {
            print("Deduplication error: \(error)")
        }
    }
}

// MARK: - App Delegate (Force Portrait)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
