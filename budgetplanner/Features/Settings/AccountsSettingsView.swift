import SwiftUI
import SwiftData

struct AccountsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.sortOrder) private var allAccounts: [Account]
    
    @State private var showingAddAccount = false
    @State private var accountToEdit: Account?
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        List {
            ForEach(allAccounts) { account in
                Button {
                    accountToEdit = account
                } label: {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color(hex: account.colorHex).opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: account.icon)
                                .font(.caption.bold())
                                .foregroundStyle(Color(hex: account.colorHex))
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(account.name)
                                .font(Theme.Fonts.body(16))
                                .foregroundStyle(Theme.Colors.primaryText)
                            
                            Text(account.balance.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                                .font(.caption)
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(Theme.Colors.secondaryText.opacity(0.5))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .onDelete(perform: deleteAccount)
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if !subscriptionManager.isPremium && allAccounts.count >= 2 {
                        showPaywall = true
                    } else {
                        showingAddAccount = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView(accountToEdit: nil)
        }
        .sheet(item: $accountToEdit) { account in
            AddAccountView(accountToEdit: account)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            OnboardingPaywallView(isCompleted: $showPaywall)
        }
    }
    
    private func deleteAccount(at offsets: IndexSet) {
        for index in offsets {
            let account = allAccounts[index]
            modelContext.delete(account)
        }
    }
}
