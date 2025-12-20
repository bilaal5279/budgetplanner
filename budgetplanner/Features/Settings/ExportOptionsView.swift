import SwiftUI

struct ExportOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    let allTransactions: [Transaction]
    
    enum ExportPeriod: String, CaseIterable, Identifiable {
        case allTime = "All Time"
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
        case custom = "Custom Range"
        
        var id: String { rawValue }
    }
    
    @State private var selectedPeriod: ExportPeriod = .allTime
    @State private var startDate: Date = Date().addingTimeInterval(-86400 * 30)
    @State private var endDate: Date = Date()
    @State private var csvURL: URL?
    
    var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedPeriod {
        case .allTime:
            return allTransactions
        case .thisMonth:
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return [] }
            return allTransactions.filter { $0.date >= startOfMonth }
        case .lastMonth:
            guard let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
                  let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth) else { return [] }
            // End of last month should be 23:59:59 technically, but <= comparison with next day start works if strictly less than, 
            // but simpler is startOfLastMonth <= date < startOfThisMonth
            return allTransactions.filter { $0.date >= startOfLastMonth && $0.date < startOfThisMonth }
        case .custom:
            // Normalize start to beginning of day and end to end of day?
            // For now, simple comparison
            return allTransactions.filter { $0.date >= startDate && $0.date <= endDate }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Time Period") {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(ExportPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if selectedPeriod == .custom {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                }
                
                Section("Summary") {
                    HStack {
                        Text("Transactions to Export")
                        Spacer()
                        Text("\(filteredTransactions.count)")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    if let url = csvURL {
                        ShareLink(item: url) {
                            HStack {
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                Text("Export CSV")
                                Spacer()
                            }
                            .bold()
                            .foregroundStyle(Theme.Colors.primaryText)
                        }
                    } else {
                        Button {
                           // Regenerate (usually done automatically by onChange)
                        } label: {
                             HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                        .disabled(true)
                    }
                }
            }
            .navigationTitle("Export Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                generateCSV()
            }
            .onChange(of: selectedPeriod) { _, _ in generateCSV() }
            .onChange(of: startDate) { _, _ in generateCSV() }
            .onChange(of: endDate) { _, _ in generateCSV() }
        }
        .presentationDetents([.medium])
    }
    
    private func generateCSV() {
        // Run on background if needed, but for simplicity here strictly main.
        // Actually, let's keep it simple.
        csvURL = CSVManager.generateCSV(from: filteredTransactions)
    }
}
