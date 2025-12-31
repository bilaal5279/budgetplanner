import SwiftUI
import SwiftData

struct AccountsView: View {
    @Query(sort: \Account.sortOrder) private var accounts: [Account]
    @Environment(\.modelContext) private var modelContext
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var isPresentingAddAccount = false
    @State private var showPaywall = false
    @State private var navigationPath = NavigationPath()
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Total Balance
                        VStack(spacing: 8) {
                            Text("Total Balance")
                                .font(Theme.Fonts.body(14))
                                .foregroundStyle(Theme.Colors.secondaryText)
                            
                            Text(totalBalance.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                                .font(Theme.Fonts.display(32))
                                .foregroundStyle(Theme.Colors.primaryText)
                        }
                        .padding(.top, 20)
                        
                        // Active Accounts Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(accounts.filter { !$0.isArchived }) { account in
                                NavigationLink(value: account) {
                                    AccountCard(account: account)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Archived Accounts
                        if !accounts.filter({ $0.isArchived }).isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Archived")
                                    .font(Theme.Fonts.display(18))
                                    .foregroundStyle(Theme.Colors.secondaryText)
                                    .padding(.leading, 8)
                                
                                ForEach(accounts.filter { $0.isArchived }) { account in
                                    NavigationLink(value: account) {
                                        ArchivedAccountRow(account: account)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Accounts")
            .navigationDestination(for: Account.self) { account in
                AccountDetailView(account: account)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Limit Check: Free users maximize at 2 accounts
                        if !subscriptionManager.isPremium && accounts.count >= 2 {
                            showPaywall = true
                        } else {
                            isPresentingAddAccount = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                

            }
            .sheet(isPresented: $isPresentingAddAccount) {
                 AddAccountView()
            }
            .fullScreenCover(isPresented: $showPaywall) {
                OnboardingPaywallView(isCompleted: $showPaywall)
            }
        }
    }
}

struct AccountCard: View {
    let account: Account
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(hex: account.colorHex),
                    Color(hex: account.colorHex).opacity(0.7) // Slightly lighter/desaturated for gradient
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Subtle Pattern overlay?
            // Keeping it clean for now, maybe add noise if requested.
            
            // Content
            VStack(alignment: .leading, spacing: 0) {
                // Top Row: Icon + Decoration
                HStack {
                    // Glassy Icon Container
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: account.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    // "Contactless" decorative icon
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(.white.opacity(0.3))
                }
                
                Spacer()
                
                // Balance (Big)
                Text(account.balance.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                    .font(Theme.Fonts.display(24)) // Increased size
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                
                // Account Name (Label)
                Text(account.name)
                    .font(Theme.Fonts.body(14).weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 4)
                    .lineLimit(1)
            }
            .padding(20)
        }
        .frame(height: 170) // Slightly taller for better proportion
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(hex: account.colorHex).opacity(0.3), radius: 15, x: 0, y: 8)
    }
}

struct ArchivedAccountRow: View {
    let account: Account
    
    var body: some View {
        HStack {
            Image(systemName: account.icon)
                .foregroundStyle(Theme.Colors.secondaryText)
            
            Text(account.name)
                .font(Theme.Fonts.body(16))
                .foregroundStyle(Theme.Colors.secondaryText)
            
            Spacer()
            
            Text(account.balance.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                .font(Theme.Fonts.body(16))
                .foregroundStyle(Theme.Colors.secondaryText)
        }
        .padding()
        .background(Theme.Colors.secondaryBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
