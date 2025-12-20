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
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background {
                    biometricManager.applicationDidEnterBackground()
                } else if newPhase == .active {
                    biometricManager.checkLockRequirement()
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

// MARK: - App Delegate (Force Portrait)
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}
