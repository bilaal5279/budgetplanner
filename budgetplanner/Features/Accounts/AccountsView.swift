import SwiftUI
import SwiftData

struct AccountsView: View {
    @Query(sort: \Account.sortOrder) private var accounts: [Account]
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingAddAccount = false
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
                        isPresentingAddAccount = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton() // Enables reordering/deletion logic if lists are used, but we might need custom logic for ForEach in ScrollView
                }
            }
            .sheet(isPresented: $isPresentingAddAccount) {
                 AddAccountView()
            }
        }
    }
}

struct AccountCard: View {
    let account: Account
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: account.colorHex).opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: account.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: account.colorHex))
            }
            
            Spacer()
            
            Text(account.name)
                .font(Theme.Fonts.body(14))
                .foregroundStyle(Theme.Colors.secondaryText)
                .lineLimit(1)
            
            Text(account.balance.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                .font(Theme.Fonts.display(20))
                .foregroundStyle(Theme.Colors.primaryText)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(16)
        .frame(height: 160)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
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
