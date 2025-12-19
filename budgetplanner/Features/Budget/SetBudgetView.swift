import SwiftUI
import SwiftData

struct SetBudgetView: View {
    @Bindable var category: Category
    @Environment(\.dismiss) var dismiss
    
    var periodStart: Date
    @Environment(\.modelContext) private var context
    
    @State private var amountString: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Header Icon
                    ZStack {
                        Circle()
                            .fill(Color(hex: category.colorHex).opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: category.icon)
                            .font(.system(size: 32))
                            .foregroundStyle(Color(hex: category.colorHex))
                    }
                    .padding(.top, 40)
                    
                    // Amount Display
                    VStack(spacing: 8) {
                        Text("Monthly Budget")
                            .font(Theme.Fonts.body(16))
                            .foregroundStyle(Theme.Colors.secondaryText)
                        
                        Text(currencyString)
                            .font(Theme.Fonts.display(64))
                            .foregroundStyle(Theme.Colors.primaryText)
                            .contentTransition(.numericText())
                    }
                    
                    Spacer()
                    
                    // Keypad
                    CustomKeypad(input: $amountString)
                    
                    // Save Button
                    Button {
                        saveBudget()
                    } label: {
                        Text("Set")
                            .font(Theme.Fonts.display(18))
                            .foregroundStyle(Theme.Colors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Theme.Colors.primaryText)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: Theme.Colors.primaryText.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle(category.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button("Remove Limit") {
                        // Remove history for this period, or all?
                        // Context: "Disable changing them for those periods".
                        // Logic: Remove EFFECTIVE budget history for this specific start date if it matches exactly.
                        if let history = category.budgetHistory?.first(where: { Calendar.current.isDate($0.startDate, equalTo: periodStart, toGranularity: .day) }) {
                            category.budgetHistory?.removeAll(where: { $0.id == history.id })
                            context.delete(history)
                        }
                        dismiss()
                    }
                    .foregroundStyle(Theme.Colors.coral)
                }
            }
            .onAppear {
                // Load effective budget for this period
                // Logic: Find history <= periodStart.
                // Assuming "effective" means the one carrying over.
                // BUT, when editing, we usually want to see what is currently applied.
                
                let sortedHistory = category.budgetHistory?.sorted(by: { $0.startDate > $1.startDate }) ?? []
                // Find the first one that is <= periodStart
                if let match = sortedHistory.first(where: { $0.startDate <= periodStart }) {
                    amountString = String(format: "%g", match.amount)
                } else if let legacyLimit = category.budgetLimit {
                    // Fallback to legacy
                    amountString = String(format: "%g", legacyLimit)
                }
            }
        }
    }
    
    private var currencyString: String {
        if amountString.isEmpty { return "$0" }
        return "$" + amountString
    }
    
    private func saveBudget() {
        guard let amount = Double(amountString) else { return }
        
        // check if we have an entry for exactly this date
        if let existing = category.budgetHistory?.first(where: { Calendar.current.isDate($0.startDate, equalTo: periodStart, toGranularity: .day) }) {
            existing.amount = amount
        } else {
            let newHistory = BudgetHistory(amount: amount, startDate: periodStart)
            category.budgetHistory?.append(newHistory)
        }
        
        // Still update legacy for fallback/backward compat if needed, or leave it?
        // Let's update it to be the "latest" known value roughly, or just ignore it.
        // Best to ignore it and rely on history relative to Now.
        
        dismiss()
    }
}
