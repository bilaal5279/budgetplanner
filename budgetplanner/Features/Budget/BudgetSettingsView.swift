import SwiftUI

struct BudgetSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("budgetPeriod") private var budgetPeriod: String = "month"
    @AppStorage("budgetStartDay") private var budgetStartDay: Int = 1
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Budget Period", selection: $budgetPeriod) {
                        Text("Monthly").tag("month")
                        Text("Weekly").tag("week")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Period Type")
                }
                
                if budgetPeriod == "month" {
                    Section {
                        Picker("Start Day", selection: $budgetStartDay) {
                            ForEach(1...28, id: \.self) { day in
                                Text("\(day.ordinalSuffix)").tag(day)
                            }
                        }
                    } header: {
                        Text("Cycle Start")
                    } footer: {
                        Text("Budget resets on this day each month.")
                    }
                } else {
                    Section {
                        Picker("Start Day", selection: $budgetStartDay) {
                            Text("Sunday").tag(1)
                            Text("Monday").tag(2)
                            Text("Tuesday").tag(3)
                            Text("Wednesday").tag(4)
                            Text("Thursday").tag(5)
                            Text("Friday").tag(6)
                            Text("Saturday").tag(7)
                        }
                    } header: {
                        Text("Week Start")
                    }
                }
            }
            .navigationTitle("Budget Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

extension Int {
    var ordinalSuffix: String {
        let ones: Int = self % 10
        let tens: Int = (self / 10) % 10
        if tens == 1 {
            return "\(self)th"
        } else if ones == 1 {
            return "\(self)st"
        } else if ones == 2 {
            return "\(self)nd"
        } else if ones == 3 {
            return "\(self)rd"
        } else {
            return "\(self)th"
        }
    }
}
