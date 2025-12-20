import SwiftUI
import SwiftData

struct AccountSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.sortOrder) private var accounts: [Account]
    
    @Binding var selectedAccount: Account?
    
    @State private var showingAddAccount = false
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(accounts) { account in
                    Button {
                        selectedAccount = account
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: account.colorHex).opacity(0.1))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: account.icon)
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(hex: account.colorHex))
                            }
                            
                            Text(account.name)
                            .font(Theme.Fonts.body(16))
                            .foregroundStyle(Theme.Colors.primaryText)
                            
                            Spacer()
                            
                            if selectedAccount == account {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Theme.Colors.mint)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(accounts[index])
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Select Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if !subscriptionManager.isPremium && accounts.count >= 2 {
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
               AddAccountView()
            }
            .fullScreenCover(isPresented: $showPaywall) {
                OnboardingPaywallView(isCompleted: $showPaywall)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// Minimal AddAccountView stub if not found, but system should find it if it exists. 
// Assuming it exists based on AccountsView usage.
