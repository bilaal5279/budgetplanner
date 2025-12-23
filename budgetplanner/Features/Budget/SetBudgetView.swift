import SwiftUI
import SwiftData

struct SetBudgetView: View {
    @Bindable var category: Category
    @Environment(\.dismiss) var dismiss
    
    var periodStart: Date
    var budgetPeriod: String
    @Environment(\.modelContext) private var context
    
    init(category: Category, periodStart: Date, budgetPeriod: String) {
        self.category = category
        self.periodStart = periodStart
        self.budgetPeriod = budgetPeriod
    }
    
    @State private var amountString: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                GeometryReader { geometry in
                    ScrollView {
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
                        .frame(minHeight: geometry.size.height)
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
                        // "Remove Limit" means set budget to 0 for this period
                        amountString = "0"
                        saveBudget()
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
        let symbol = CurrencyManager.shared.getSymbol(for: CurrencyManager.shared.currencyCode)
        if amountString.isEmpty { return "\(symbol)0" }
        return symbol + amountString
    }
    
    private func saveBudget() {
        guard let amount = Double(amountString) else { return }
        let calendar = Calendar.current
        
        // CHECKPOINTING LOGIC
        // If we are editing a PAST period, we must ensure that the NEXT period 
        // has an explicit history entry so that this change doesn't propagate forward.
        // Unless the next period is ALSO in the past? No, the user wants "this period only".
        
        // 1. Calculate next period start
        let nextStart: Date
        if budgetPeriod == "week" {
            nextStart = calendar.date(byAdding: .weekOfYear, value: 1, to: periodStart)!
        } else {
            nextStart = calendar.date(byAdding: .month, value: 1, to: periodStart)!
        }
        
        // 2. Check if we need to secure the future state
        // Only if periodStart is strictly BEFORE the current period start.
        // Actually, logic is: Update this period. 
        // If next period doesn't have an explicit entry, it relies on this one (or older).
        // If we change this one, next period changes too (inheritance).
        // To genericize: "Changes will only affect this period".
        // So we must snapshot the OLD effective budget into the next period, IF it doesn't have one.
        
        // Is periodStart < Current Period Start? (Roughly, is it past?)
        // Let's just always enforce "Next Period Checkpoint" if next period <= today?
        // Simpler: If sorting by date, check if there is an entry at or after nextStart.
        // Actually, just check exactly nextStart. If not there, insert "old effective".
        
        let sortedHistory = category.budgetHistory?.sorted(by: { $0.startDate > $1.startDate }) ?? []
        
        // Check if next period has an entry
        let hasNextEntry = sortedHistory.contains(where: { calendar.isDate($0.startDate, equalTo: nextStart, toGranularity: .day) })
        
        if !hasNextEntry {
            // Check if nextStart is in the future relative to "Now"? 
            // If I edit August, and it's December. I need to checkpoint September.
            // If I edit December (Current), Next is Jan. Jan is future. Maybe I WANT Jan to change?
            // User requirement: "wont affect the new budgets unless they go to the new period".
            // Implies: If I change Current, Future changes. If I change Past, Future (relative to Past) shouldn't change.
            
            // So, check if periodStart is in the PAST relative to TODAY.
            let isPastEdit = periodStart < calendar.date(byAdding: .day, value: -1, to: Date())! // Rough check or use startOfDay
            
            if isPastEdit {
                // Determine what the budgets was effectively for the next period BEFORE this edit
                // Which is the same as effective budget for this period BEFORE this edit.
                // We find the effective amount currently.
                 if let match = sortedHistory.first(where: { $0.startDate <= periodStart }) {
                     let oldAmount = match.amount
                     // Create checkpoint for next period
                     let checkpoint = BudgetHistory(amount: oldAmount, startDate: nextStart)
                     category.budgetHistory?.append(checkpoint)
                 } else if let legacy = category.budgetLimit {
                     let checkpoint = BudgetHistory(amount: legacy, startDate: nextStart)
                     category.budgetHistory?.append(checkpoint)
                 }
            }
        }
        
        // NOW apply the change to THIS period
        if let existing = category.budgetHistory?.first(where: { Calendar.current.isDate($0.startDate, equalTo: periodStart, toGranularity: .day) }) {
            existing.amount = amount
        } else {
            let newHistory = BudgetHistory(amount: amount, startDate: periodStart)
            category.budgetHistory?.append(newHistory)
        }
        
        dismiss()
    }
}
