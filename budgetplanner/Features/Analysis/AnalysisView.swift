import SwiftUI
import SwiftData
import Charts

struct AnalysisView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    
    @State private var selectedTab: AnalysisTab = .expense
    @State private var currentDate: Date = Date()
    @State private var periodType: NavigationPeriod = .month
    @State private var chartType: AnalysisChartType = .bar
    
    // Interactive Chart State
    @State private var selectedChartDate: Date?
    @State private var selectedChartAmount: Double?
    
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    
    // MARK: - Computed Data
    
    // Current Period Range
    var currentRange: (start: Date, end: Date) {
        (currentDate.startOfPeriod(periodType), currentDate.endOfPeriod(periodType))
    }
    
    // Previous Period Range (for trends)
    var previousRange: (start: Date, end: Date) {
        // Map periodType to AnalysisPeriod logic or do it here
        // Using simple date math for now corresponding to AnalysisPeriod logic
        mapToAnalysisPeriod(periodType).previousPeriodRange(from: currentRange.start)
    }
    
    var filteredTransactions: [Transaction] {
        let range = currentRange
        return allTransactions.filter { $0.date >= range.start && $0.date < range.end }
    }
    
    var previousTransactions: [Transaction] {
        let range = previousRange
        return allTransactions.filter { $0.date >= range.start && $0.date < range.end }
    }
    
    // Tab Specific
    var tabTransactions: [Transaction] {
        switch selectedTab {
        case .expense: return filteredTransactions.filter { $0.type == .expense }
        case .income: return filteredTransactions.filter { $0.type == .income }
        case .transactions: return filteredTransactions
        }
    }
    
    // Financials
    var totalIncome: Double { filteredTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount } }
    var totalExpense: Double { filteredTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount } }
    var netBalance: Double { totalIncome - totalExpense }
    
    var previousTotalForTab: Double {
        switch selectedTab {
        case .expense: return previousTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        case .income: return previousTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        default: return 0
        }
    }
    
    var averagePerDay: Double {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: currentRange.start, to: currentRange.end).day ?? 1
        if selectedTab == .transactions { return 0 }
        let total = selectedTab == .income ? totalIncome : totalExpense
        return total / Double(max(1, days))
    }
    
    // Top Category Calculation
    var topCategory: (name: String, amount: Double, icon: String, color: String)? {
        let expenses = filteredTransactions.filter { $0.type == .expense }
        let grouped = Dictionary(grouping: expenses, by: { $0.category ?? Category(name: "Uncategorized", icon: "questionmark", colorHex: "808080") })
        
        let sorted = grouped.map { (category, txs) in
            (category, txs.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.1 > $1.1 }
        
        if let first = sorted.first {
            return (first.0.name, first.1, first.0.icon, first.0.colorHex)
        }
        return nil
    }
    
    var trend: TrendResult? {
        // Calculate based on selected tab amount vs previous period amount
        let current = selectedTab == .income ? totalIncome : (selectedTab == .expense ? totalExpense : 0)
        return TrendCalculator.calculateTrend(current: current, previous: previousTotalForTab)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // MARK: - Premium Header
                    VStack(spacing: 8) {
                        // Date Navigator
                        HStack {
                            Button { stepDate(by: -1) } label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                                    .font(.title3)
                            }
                            
                            Menu {
                                Picker("Period", selection: $periodType) {
                                    ForEach(NavigationPeriod.allCases) { p in
                                        Text(p.rawValue).tag(p)
                                    }
                                }
                            } label: {
                                Text(currentDate.formatPeriod(periodType))
                                    .font(.headline)
                                    .foregroundStyle(Theme.Colors.primaryText)
                            }
                            
                            Button { stepDate(by: 1) } label: {
                                Image(systemName: "chevron.right.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                                    .font(.title3)
                            }
                        }
                        .padding(.top, 4)
                        
                        // Big Number + Trend
                        VStack(spacing: 4) {
                            // Logic: If chart selection active, show that. Else show period total/net.
                            Group {
                                if let selected = selectedChartAmount {
                                    Text(selected.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                                        .foregroundStyle(Theme.Colors.primaryText)
                                } else {
                                    Text((selectedTab == .income ? totalIncome : (selectedTab == .expense ? totalExpense : netBalance)).formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                                        .foregroundStyle(Theme.Colors.primaryText)
                                }
                            }
                            .font(Theme.Fonts.display(36))
                            .contentTransition(.numericText())
                            .animation(.snappy, value: selectedChartAmount)
                            
                            // Show trend only if NO selection (otherwise it's confusing)
                            if selectedChartAmount == nil, let t = trend, selectedTab != .transactions {
                                HStack(spacing: 4) {
                                    Image(systemName: t.isIncrease ? "arrow.up.right" : "arrow.down.right")
                                    Text("\(t.percentage.formatted(.number.precision(.fractionLength(1))))%")
                                    Text("vs last \(periodType.rawValue.lowercased())")
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                }
                                .font(.caption.weight(.medium))
                                .foregroundStyle(t.isIncrease ? (selectedTab == .income ? Theme.Colors.mint : Theme.Colors.coral) : (selectedTab == .income ? Theme.Colors.coral : Theme.Colors.mint))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.Colors.secondaryBackground)
                                .clipShape(Capsule())
                            } else if let date = selectedChartDate {
                                // Show Date of selection
                                Text(date.formatted(date: .complete, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(Theme.Colors.secondaryText)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    .background(Theme.Colors.background)
                    
                    ScrollView {
                        VStack(spacing: 24) {
                            
                            // MARK: - Insights Deck
                            InsightsCarousel(
                                income: totalIncome,
                                expense: totalExpense,
                                net: netBalance,
                                avgPerDay: averagePerDay,
                                dailySubtitle: selectedTab == .income ? "Income" : "Spending"
                            )
                            
                            // MARK: - Tab Selection
                            Picker("Type", selection: $selectedTab) {
                                ForEach(AnalysisTab.allCases, id: \.self) { tab in
                                    Text(tab.rawValue).tag(tab)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)

                            // MARK: - Contextual Content
                            if selectedTab == .transactions {
                                TransactionsList(transactions: filteredTransactions)
                            } else {
                                // Chart for Income or Expense
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Trends")
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        // Chart Type Toggle (Only for Expense usually, but can look cool for Income too)
                                        if selectedTab != .income {
                                            Picker("Graph", selection: $chartType) {
                                                Image(systemName: "chart.bar.fill").tag(AnalysisChartType.bar)
                                                Image(systemName: "chart.pie.fill").tag(AnalysisChartType.pie)
                                            }
                                            .pickerStyle(.segmented)
                                            .frame(width: 100)
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    if chartType == .bar || selectedTab == .income {
                                        SpendingChart(
                                            transactions: tabTransactions,
                                            period: mapToAnalysisPeriod(periodType),
                                            customDateRange: currentRange,
                                            selectedDate: $selectedChartDate,
                                            selectedAmount: $selectedChartAmount
                                        )
                                        .padding(.horizontal)
                                        .transition(.opacity.combined(with: .move(edge: .leading)))
                                    } else {
                                        CategoryPieChart(transactions: tabTransactions)
                                            .padding(.horizontal)
                                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                                    }
                                }
                                
                                if selectedTab == .expense {
                                    // Expense Mode: Category Breakdown
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text("Where your money went")
                                                .font(.headline)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        
                                        // Simplified usage (logic inside CategoryBreakdownList)
                                        CategoryBreakdownList(transactions: tabTransactions, showPaywall: $showPaywall)
                                            .padding(.horizontal)
                                    }
                                } else if selectedTab == .income {
                                    // Income Mode: Recent Inflows (No category breakdown for income usually)
                                    VStack(alignment: .leading, spacing: 16) {
                                        HStack {
                                            Text("Recent Income")
                                                .font(.headline)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        
                                        // Simple list of income transactions
                                        LazyVStack(spacing: 12) {
                                            ForEach(tabTransactions.prefix(5)) { transaction in
                                                HStack {
                                                    Circle()
                                                        .fill(Theme.Colors.mint.opacity(0.1))
                                                        .frame(width: 40, height: 40)
                                                        .overlay {
                                                            Image(systemName: "arrow.down")
                                                                .foregroundStyle(Theme.Colors.mint)
                                                                .font(.system(size: 14, weight: .bold))
                                                        }
                                                    
                                                    VStack(alignment: .leading, spacing: 4) {
                                                        Text(transaction.note.isEmpty ? "Income" : transaction.note)
                                                            .font(.body.weight(.medium))
                                                            .foregroundStyle(Theme.Colors.primaryText)
                                                        
                                                        Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                                                            .font(.caption)
                                                            .foregroundStyle(Theme.Colors.secondaryText)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    Text(transaction.amount.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                                                        .font(.body.weight(.semibold))
                                                        .foregroundStyle(Theme.Colors.mint)
                                                }
                                                .padding(12)
                                                .background(Theme.Colors.secondaryBackground)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showPaywall) {
                OnboardingPaywallView(isCompleted: $showPaywall)
            }
        }
    }
    
    private func stepDate(by value: Int) {
        let calendar = Calendar.current
        switch periodType {
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: value, to: currentDate) ?? currentDate
        case .month:
            currentDate = calendar.date(byAdding: .month, value: value, to: currentDate) ?? currentDate
        case .year:
            currentDate = calendar.date(byAdding: .year, value: value, to: currentDate) ?? currentDate
        }
    }
    
    private func mapToAnalysisPeriod(_ p: NavigationPeriod) -> AnalysisPeriod {
        switch p {
        case .week: return .thisWeek
        case .month: return .thisMonth
        case .year: return .thisYear
        }
    }
}
// Keep CategoryBreakdownList unchanged or lightly refined

enum AnalysisChartType {
    case bar
    case pie
}



// Helper for breakdown list
struct CategoryBreakdownList: View {
    let transactions: [Transaction]
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Binding var showPaywall: Bool
    
    var grouped: [(Category, Double)] {
        let g = Dictionary(grouping: transactions, by: { $0.category ?? Category(name: "Uncategorized", icon: "questionmark", colorHex: "808080") })
        return g.map { (category, txs) in
            (category, txs.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.1 > $1.1 }
    }
    
    var total: Double {
        grouped.reduce(0) { $0 + $1.1 }
    }
    
    // Helper to get transactions for a specific category
    func transactions(for category: Category) -> [Transaction] {
        return transactions.filter { ($0.category?.id == category.id) || ($0.category == nil && category.name == "Uncategorized") }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Determine how many to fully show
            // Premium: All
            // Free: Top 2
            let visibleCount = subscriptionManager.isPremium ? grouped.count : 2
            
            // 1. Visible, Unlocked Categories
            ForEach(grouped.prefix(visibleCount), id: \.0.id) { (category, amount) in
                NavigationLink(destination: CategoryDetailView(categoryName: category.name, transactions: transactions(for: category))) {
                    CategoryBreakdownRow(category: category, amount: amount, total: total)
                }
            }
            
            // 2. Blurred, Locked Categories (Premium Teaser)
            if !subscriptionManager.isPremium && grouped.count > 2 {
                ZStack {
                    // showing a few more items, but blurred
                    VStack(spacing: 12) {
                        ForEach(grouped.dropFirst(2).prefix(3), id: \.0.id) { (category, amount) in
                            CategoryBreakdownRow(category: category, amount: amount, total: total)
                                .blur(radius: 6)
                                .accessibilityHidden(true)
                        }
                    }
                    
                    // Unlock Button Overlay
                    Button {
                        showPaywall = true
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "lock.fill")
                                .font(.title2)
                                .foregroundStyle(Theme.Colors.mint)
                                .padding(12)
                                .background(Theme.Colors.mint.opacity(0.1))
                                .clipShape(Circle())
                            
                            Text("Unlock Breakdown")
                                .font(Theme.Fonts.body(16).weight(.bold))
                                .foregroundStyle(Theme.Colors.primaryText)
                            
                            Text("See exactly where you spend")
                                .font(Theme.Fonts.body(12))
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .background(Theme.Colors.secondaryBackground.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Theme.Colors.mint.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

// Extracted Row for Reuse
struct CategoryBreakdownRow: View {
    let category: Category
    let amount: Double
    let total: Double
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: category.colorHex))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: category.icon)
                        .foregroundStyle(.white)
                        .font(.system(size: 18))
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(category.name)
                    .font(Theme.Fonts.body(16).weight(.medium))
                    .foregroundStyle(Theme.Colors.primaryText)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                    .font(Theme.Fonts.body(16).weight(.semibold))
                    .foregroundStyle(Theme.Colors.primaryText)
                
                Text(total > 0 ? "\((amount/total * 100).formatted(.number.precision(.fractionLength(0))))%" : "0%")
                    .font(.caption)
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Theme.Colors.secondaryText)
        }
        .padding(12)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Subviews

struct PeriodPill: View {
    let period: AnalysisPeriod
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(period.rawValue)
                .font(Theme.Fonts.body(14))
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Theme.Colors.background : Theme.Colors.secondaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Theme.Colors.primaryText : Theme.Colors.secondaryBackground)
                )
        }
        .buttonStyle(.plain)
    }
}

// No subviews needed as they are integrated into the main view or separate files.
