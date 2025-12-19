import SwiftUI
import SwiftData
import Charts

struct AnalysisView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    
    enum TimePeriod: String, CaseIterable, Identifiable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        var id: String { rawValue }
    }
    
    @State private var selectedPeriod: TimePeriod = .month
    
    var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        return allTransactions.filter { tx in
            // Must be Expense for spending analysis
            guard tx.type == .expense else { return false }
            
            switch selectedPeriod {
            case .week:
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
                return tx.date >= weekAgo
            case .month:
                let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
                return tx.date >= monthAgo
            case .year:
                let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
                return tx.date >= yearAgo
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Time Filter
                        Picker("Period", selection: $selectedPeriod) {
                            ForEach(TimePeriod.allCases) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        if filteredTransactions.isEmpty {
                            ContentUnavailableView(
                                "No Data",
                                systemImage: "chart.xyaxis.line",
                                description: Text("No expenses found for this period.")
                            )
                            .padding(.top, 40)
                        } else {
                            // 2. Breakdown Donut
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Where your money went")
                                    .font(Theme.Fonts.display(18))
                                    .foregroundStyle(Theme.Colors.primaryText)
                                
                                CategoryBreakdownChart(transactions: filteredTransactions)
                            }
                            .padding(20)
                            .background(Theme.Colors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal)
                            
                            // 3. Spending Trends Bar
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Spending Trend")
                                    .font(Theme.Fonts.display(18))
                                    .foregroundStyle(Theme.Colors.primaryText)
                                
                                SpendingChart(transactions: filteredTransactions, period: selectedPeriod)
                            }
                            .padding(20)
                            .background(Theme.Colors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .padding(.horizontal)
                            
                            // 4. Quick Highlights
                            HStack(spacing: 16) {
                                HighlightCard(
                                    title: "Daily Average",
                                    value: calculateDailyAverage(),
                                    icon: "calendar",
                                    color: Theme.Colors.mint
                                )
                                
                                HighlightCard(
                                    title: "Top Category",
                                    value: calculateTopCategory(),
                                    icon: "trophy.fill",
                                    color: Theme.Colors.coral
                                )
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Analysis")
        }
    }
    
    private func calculateDailyAverage() -> String {
        let total = filteredTransactions.reduce(0) { $0 + $1.amount }
        let days: Double = selectedPeriod == .week ? 7 : (selectedPeriod == .month ? 30 : 365)
        return String(format: "$%.0f", total / days)
    }
    
    private func calculateTopCategory() -> String {
        let grouped = Dictionary(grouping: filteredTransactions) { $0.category?.name ?? "Other" }
        
        let categoryTotals = grouped.map { key, transactions in
            (key: key, total: transactions.reduce(0) { $0 + $1.amount })
        }
        
        let topCategory = categoryTotals.max { $0.total < $1.total }
        return topCategory?.key ?? "--"
    }
}

struct HighlightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(Theme.Fonts.display(20))
                .foregroundStyle(Theme.Colors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(title)
                .font(Theme.Fonts.body(12))
                .foregroundStyle(Theme.Colors.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
