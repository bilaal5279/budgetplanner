import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var accountToEdit: Account?
    
    @State private var name: String = ""
    @State private var balanceString: String = ""
    @State private var selectedIcon: String = "creditcard.fill"
    @State private var selectedColor: String = "54A0FF"
    
    let icons = ["creditcard.fill", "banknote.fill", "building.columns.fill", "wallet.pass.fill", "giftcard.fill", "bag.fill", "cart.fill", "chart.pie.fill"]
    let colors = ["54A0FF", "2ECC71", "F1C40F", "E74C3C", "9B59B6", "34495E", "E67E22", "1ABC9C"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 32) {
                            // MARK: - Preview Card
                            VStack(spacing: 12) {
                                Text("Preview")
                                    .font(Theme.Fonts.body(14))
                                    .foregroundStyle(Theme.Colors.secondaryText)
                                
                                AccountPreviewCard(
                                    name: name.isEmpty ? "Account Name" : name,
                                    balance: Double(balanceString) ?? 0.0,
                                    icon: selectedIcon,
                                    colorHex: selectedColor
                                )
                            }
                            .padding(.top, 20)
                            
                            // MARK: - Inputs
                            VStack(spacing: 24) {
                                // Name Input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Name")
                                        .font(Theme.Fonts.body(14))
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                        .padding(.leading, 4)
                                    
                                    TextField("e.g. Bank Card", text: $name)
                                        .font(Theme.Fonts.display(20))
                                        .padding()
                                        .background(Theme.Colors.secondaryBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                        .submitLabel(.next)
                                }
                                
                                // Balance Input
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Initial Balance")
                                        .font(Theme.Fonts.body(14))
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                        .padding(.leading, 4)
                                    
                                    HStack(spacing: 4) {
                                        Text("$")
                                            .font(Theme.Fonts.display(20))
                                            .foregroundStyle(Theme.Colors.secondaryText)
                                        
                                        TextField("0.00", text: $balanceString)
                                            .font(Theme.Fonts.display(20))
                                            .keyboardType(.decimalPad)
                                    }
                                    .padding()
                                    .background(Theme.Colors.secondaryBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                
                                // Appearance Selections
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Appearance")
                                        .font(Theme.Fonts.body(14))
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                        .padding(.leading, 4)
                                    
                                    // Colors
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(colors, id: \.self) { color in
                                                Circle()
                                                    .fill(Color(hex: color))
                                                    .frame(width: 44, height: 44)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Theme.Colors.primaryText, lineWidth: selectedColor == color ? 3 : 0)
                                                    )
                                                    .onTapGesture {
                                                        withAnimation(.spring(response: 0.3)) {
                                                            selectedColor = color
                                                        }
                                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                    }
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                    }
                                    
                                    // Icons
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 16) {
                                            ForEach(icons, id: \.self) { icon in
                                                ZStack {
                                                    Circle()
                                                        .fill(Theme.Colors.secondaryBackground)
                                                        .frame(width: 50, height: 50)
                                                    
                                                    Image(systemName: icon)
                                                        .font(.system(size: 20))
                                                        .foregroundStyle(selectedIcon == icon ? Color(hex: selectedColor) : Theme.Colors.secondaryText)
                                                }
                                                .overlay(
                                                    Circle()
                                                        .stroke(Color(hex: selectedColor), lineWidth: selectedIcon == icon ? 2 : 0)
                                                )
                                                .onTapGesture {
                                                    withAnimation(.spring(response: 0.3)) {
                                                        selectedIcon = icon
                                                    }
                                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 8)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 100)
                    }
                    
                    // MARK: - Save Button Container
                    VStack {
                        Button {
                            saveAccount()
                        } label: {
                            Text("Save Account")
                                .font(Theme.Fonts.display(18))
                                .foregroundStyle(Theme.Colors.background)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(hex: selectedColor))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: Color(hex: selectedColor).opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 10)
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.top, 10)
                    .background(Theme.Colors.background) // Ensure background covers list when scrolling
                    .ignoresSafeArea(.keyboard)
                }
            }
            .navigationTitle(accountToEdit == nil ? "New Account" : "Edit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let account = accountToEdit {
                    name = account.name
                    balanceString = String(format: "%.2f", account.balance)
                    selectedIcon = account.icon
                    selectedColor = account.colorHex
                }
            }
        }
    }
    
    private func saveAccount() {
        if let account = accountToEdit {
            account.name = name
            account.balance = Double(balanceString) ?? 0.0
            account.icon = selectedIcon
            account.colorHex = selectedColor
        } else {
            let account = Account(
                name: name,
                balance: Double(balanceString) ?? 0.0,
                icon: selectedIcon,
                colorHex: selectedColor,
                sortOrder: 99
            )
            modelContext.insert(account)
        }
        
        // Feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
}

// MARK: - Preview Component
struct AccountPreviewCard: View {
    let name: String
    let balance: Double
    let icon: String
    let colorHex: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex).opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: colorHex))
            }
            
            Spacer()
            
            Text(name)
                .font(Theme.Fonts.body(14))
                .foregroundStyle(Theme.Colors.secondaryText)
                .lineLimit(1)
            
            Text(String(format: "$%.2f", balance))
                .font(Theme.Fonts.display(20))
                .foregroundStyle(Theme.Colors.primaryText)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding(16)
        .frame(width: 160, height: 160)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 10)
    }
}
