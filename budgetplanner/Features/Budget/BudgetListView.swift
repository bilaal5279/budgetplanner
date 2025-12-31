import SwiftUI
import SwiftData

struct BudgetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]
    @Query(sort: \Transaction.date) private var allTransactions: [Transaction]
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    @State private var isPresentingAddCategory = false
    @State private var showPaywall = false
    @State private var isPresentingSettings = false
    @State private var selectedDate = Date()
    @State private var categoryToEdit: Category?
    @State private var pendingCategoryEdit: Category?
    @State private var showPastEditAlert = false
    
    // Deletion
    @State private var categoryToDelete: Category?
    @State private var showDeleteConfirmation = false
    
    // Settings
    @AppStorage("budgetPeriod") private var budgetPeriod: String = "month"
    @AppStorage("budgetStartDay") private var budgetStartDay: Int = 1
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var periodDateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        
        if budgetPeriod == "week" {
            // Week logic
            // Start day adjustment logic involves finding the previous occurrence of "budgetStartDay" weekday
            // For simplicity, let's assume system week first, but respecting start day preference
            // "budgetStartDay" in settings: 1=Sun, 2=Mon...
            let weekday = budgetStartDay
            

            // Adjust if start is in future of selectedDate (can happen depending on calculation)
            // Safer logic: Find previous execution of weekday
            let currentWeekday = calendar.component(.weekday, from: selectedDate)
            let daysToSubtract = (currentWeekday - weekday + 7) % 7
            let alignedStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: selectedDate)!
            let normalizedStart = calendar.startOfDay(for: alignedStart)
            
            let end = calendar.date(byAdding: .day, value: 7, to: normalizedStart)!
            return (normalizedStart, end)
            
        } else {
            // Month logic
            // If today is Jan 5, and start day is 1 -> Jan 1 to Feb 1
            // If today is Jan 5, and start day is 25 -> Dec 25 to Jan 25
            
            let day = calendar.component(.day, from: selectedDate)
            var startComponents = calendar.dateComponents([.year, .month], from: selectedDate)
            
            if day < budgetStartDay {
                // We are in the period started last month
                startComponents.month = (startComponents.month ?? 1) - 1
            }
            startComponents.day = min(budgetStartDay, 28) // Simple clamp
            
            let start = calendar.date(from: startComponents)!
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return (start, end)
        }
    }
    
    var filteredTransactions: [Transaction] {
        let range = periodDateRange
        return allTransactions.filter {
            $0.date >= range.start && $0.date < range.end && $0.type == .expense
        }
    }
    
    // Prevent navigating to future if "only if its happened" rule applies?
    // "go to the previous period or future period etc (only if its happened)"
    // Interpreted as: Can't go beyond today's real period? Or just standard calendar constraint?
    // Let's constrain to not going BEYOND current real date's period
    var canGoForward: Bool {
        let range = periodDateRange
        return range.end < Date() // If end of filtered period is before Now, we can go forward
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Period Navigator
                    HStack {
                        Button {
                             movePeriod(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding()
                                .foregroundStyle(Theme.Colors.primaryText)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text(periodTitle)
                                .font(Theme.Fonts.display(16))
                                .foregroundStyle(Theme.Colors.primaryText)
                            Text(periodSubtitle)
                                .font(Theme.Fonts.body(12))
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                        .onTapGesture {
                            // Quick jump to today?
                            withAnimation { selectedDate = Date() }
                        }
                        
                        Spacer()
                        
                        Button {
                            if canGoForward {
                                movePeriod(by: 1)
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .padding()
                                .foregroundStyle(canGoForward ? Theme.Colors.primaryText : Theme.Colors.secondaryText.opacity(0.3))
                        }
                        .disabled(!canGoForward)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .background(Theme.Colors.background) // sticky header effect if needed
                    
                    if categories.isEmpty {
                        ContentUnavailableView("No Budgets", systemImage: "chart.bar.doc.horizontal", description: Text("Create a category to start budgeting."))
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Overall Summary Card
                                BudgetSummaryCard(categories: categories, transactions: filteredTransactions, dateRange: periodDateRange, totalBudget: totalBudgetForPeriod)
                                
                                // Category Grid
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(categories) { category in
                                        Button {
                                            if isPastPeriod {
                                                pendingCategoryEdit = category
                                                showPastEditAlert = true
                                            } else {
                                                categoryToEdit = category
                                            }
                                        } label: {
                                            BudgetGridItem(
                                                category: category,
                                                spent: calculateSpent(for: category),
                                                budgetLimit: effectiveBudget(for: category),
                                                isPastPeriod: isPastPeriod
                                            )
                                        }
                                        .buttonStyle(.plain) // remove default button flash if desired
                                        .opacity(isPastPeriod ? 1.0 : 1.0) // Maintain visibility
                                        .contextMenu {
                                            if category.isCustom {
                                                Button(role: .destructive) {
                                                    categoryToDelete = category
                                                    showDeleteConfirmation = true
                                                } label: {
                                                    Label("Delete Category", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 100)
                            }
                            .padding()
                        }
                        .contentShape(Rectangle()) // Ensure swipe works on empty areas
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width < -50 {
                                        // Swipe Left -> Future
                                        if canGoForward { withAnimation { movePeriod(by: 1) } }
                                    } else if value.translation.width > 50 {
                                        // Swipe Right -> Past
                                        withAnimation { movePeriod(by: -1) }
                                    }
                                }
                        )
                    }
                }
            }
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresentingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Theme.Colors.primaryText)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Count all custom categories (regardless of expense/income type for now, or total)
                        // Query 'categories' is already available
                        let customCount = categories.filter { $0.isCustom }.count
                        
                        if !subscriptionManager.isPremium && customCount >= 1 {
                            showPaywall = true
                        } else {
                            isPresentingAddCategory = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Theme.Colors.primaryText)
                            .contentShape(Rectangle())
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddCategory) {
                AddCategoryView()
            }
            .fullScreenCover(isPresented: $showPaywall) {
                OnboardingPaywallView(isCompleted: $showPaywall)
            }
            .sheet(isPresented: $isPresentingSettings) {
                BudgetSettingsView()
                    .presentationDetents([.medium])
            }
            .alert("Edit Past Budget?", isPresented: $showPastEditAlert) {
                Button("Cancel", role: .cancel) { pendingCategoryEdit = nil }
                Button("Edit Anyway") {
                    if let cat = pendingCategoryEdit {
                        categoryToEdit = cat
                    }
                }
            } message: {
                Text("This budget is for a previous period. Changes will only affect this period and won't change your current or future budgets.")
            }
            .fullScreenCover(item: $categoryToEdit) { category in
                SetBudgetView(category: category, periodStart: periodDateRange.start, budgetPeriod: budgetPeriod)
            }
            .confirmationDialog("Delete Category?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let category = categoryToDelete {
                        deleteCategory(category)
                    }
                }
                Button("Cancel", role: .cancel) { categoryToDelete = nil }
            } message: {
                Text("Are you sure? This will delete the category and all associated transactions.")
            }
        }
    }
    
    // Logic
    private func movePeriod(by value: Int) {
        let calendar = Calendar.current
        if budgetPeriod == "week" {
            if let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
                selectedDate = newDate
            }
        } else {
             if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
                 selectedDate = newDate
             }
        }
    }
    
    private var isPastPeriod: Bool {
        // If end of period is before today's start of day (basically)
        return periodDateRange.end < Calendar.current.startOfDay(for: Date())
    }
    
    private var periodTitle: String {
        let range = periodDateRange
        let df = DateFormatter()
        if budgetPeriod == "week" {
            df.dateFormat = "MMM d"
            return "\(df.string(from: range.start)) - \(df.string(from: range.end.addingTimeInterval(-1)))"
        } else {
            df.dateFormat = "MMMM yyyy"
            return df.string(from: range.start)
        }
    }
    
    private var periodSubtitle: String {
        let calendar = Calendar.current
        if calendar.isDate(selectedDate, equalTo: Date(), toGranularity: budgetPeriod == "week" ? .weekOfYear : .month) {
            return "Current Period"
        }
        return "History"
    }
    
    private func calculateSpent(for category: Category) -> Double {
        filteredTransactions.filter { $0.category == category }.reduce(0) { $0 + $1.amount }
    }
    
    private func effectiveBudget(for category: Category) -> Double? {
        // Find latest history that starts on or before current period start
        let sortedHistory = category.budgetHistory?.sorted(by: { $0.startDate > $1.startDate }) ?? []
        if let match = sortedHistory.first(where: { $0.startDate <= periodDateRange.start }) {
            // Treat 0 as "No Budget"
            return match.amount > 0.01 ? match.amount : nil
        }
        // Fallback to legacy limit if exists and no history overrides it?
        // Or assume legacy limit applies from infinite past?
        // Let's assume legacy limit is valid if no history found.
        return category.budgetLimit
    }
    
    private var totalBudgetForPeriod: Double {
        categories.reduce(0) { $0 + (effectiveBudget(for: $1) ?? 0) }
    }
    
    private func deleteCategory(_ category: Category) {
        guard category.isCustom else { return }
        modelContext.delete(category)
        categoryToDelete = nil
    }
}

// MARK: - Subviews

struct BudgetGridItem: View {
    let category: Category
    let spent: Double
    let budgetLimit: Double?
    let isPastPeriod: Bool
    
    var progress: Double {
        guard let limit = budgetLimit, limit > 0 else { return 0 }
        return min(spent / limit, 1.0)
    }
    
    var isOverBudget: Bool {
        guard let limit = budgetLimit else { return false }
        return spent > limit
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon + Progress Ring
            ZStack {
                // Background Ring
                Circle()
                    .stroke(Theme.Colors.secondaryText.opacity(0.1), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                // Progress Ring
                if let _ = budgetLimit {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            isOverBudget ? Theme.Colors.coral : Theme.Colors.mint,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: (isOverBudget ? Theme.Colors.coral : Theme.Colors.mint).opacity(0.5), radius: 5)
                } else {
                    // Set Button placeholder look
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .foregroundStyle(Theme.Colors.secondaryText.opacity(0.3))
                        .frame(width: 60, height: 60)
                }
                
                // Icon
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(Color(hex: category.colorHex))
            }
            .padding(.top, 8)
            
            // Text Info
            VStack(spacing: 4) {
                Text(category.name)
                    .font(Theme.Fonts.body(14))
                    .foregroundStyle(Theme.Colors.primaryText)
                    .lineLimit(1)
                
                if let limit = budgetLimit {
                    Text("\(spent.formatted(.currency(code: CurrencyManager.shared.currencyCode))) / \(limit.formatted(.currency(code: CurrencyManager.shared.currencyCode)))")
                        .font(Theme.Fonts.body(12))
                        .foregroundStyle(Theme.Colors.secondaryText)
                } else {
                    if spent > 0 {
                        Text(spent.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                            .font(Theme.Fonts.body(12))
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                    if !isPastPeriod {
                        Text("Set")
                            .font(Theme.Fonts.body(12))
                            .foregroundStyle(Theme.Colors.mint)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Theme.Colors.secondaryBackground.opacity(0.5)) // Added subtle card bg
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(isPastPeriod ? 0.7 : 1.0)
    }
}

struct BudgetSummaryCard: View {
    let categories: [Category]
    let transactions: [Transaction]
    let dateRange: (start: Date, end: Date)
    let totalBudget: Double
    
    var totalSpent: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
    
    var daysLeft: Int {
        let calendar = Calendar.current
        let end = dateRange.end
        let now = Date()
        
        // If period is past, 0 days left
        if end < now { return 0 }
        
        let components = calendar.dateComponents([.day], from: now, to: end)
        return max(0, components.day ?? 0)
    }
    
    var body: some View {
        HStack(spacing: 24) {
            // Main Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 100, height: 100)
                
                if totalBudget > 0 {
                    Circle()
                        .trim(from: 0, to: min(totalSpent / totalBudget, 1.0))
                        .stroke(
                            AngularGradient(
                                colors: [Theme.Colors.mint, Theme.Colors.mint.opacity(0.8)],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Theme.Colors.mint.opacity(0.3), radius: 10)
                }
                
                VStack(spacing: 2) {
                    Text(totalBudget > 0 ? String(format: "%.0f%%", (totalSpent/totalBudget)*100) : "--")
                        .font(Theme.Fonts.display(20))
                        .foregroundStyle(Color.white)
                    Text("Used")
                        .font(Theme.Fonts.body(12))
                        .foregroundStyle(Color.white.opacity(0.6))
                }
            }
            
            // Text Stats
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Spent")
                        .font(Theme.Fonts.body(14))
                        .foregroundStyle(Color.white.opacity(0.7))
                    Text(totalSpent.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                        .font(Theme.Fonts.display(28))
                        .foregroundStyle(Color.white)
                }
                
                HStack(spacing: 16) {
                     VStack(alignment: .leading, spacing: 4) {
                        Text("Budget")
                            .font(Theme.Fonts.body(12))
                            .foregroundStyle(Color.white.opacity(0.7))
                        Text(totalBudget.formatted(.currency(code: CurrencyManager.shared.currencyCode)))
                            .font(Theme.Fonts.body(16))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Days Left")
                            .font(Theme.Fonts.body(12))
                            .foregroundStyle(Color.white.opacity(0.7))
                        Text("\(daysLeft)")
                            .font(Theme.Fonts.body(16))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                }
            }
            
            Spacer()
        }
        .padding(24)
        .background(
            ZStack {
                Theme.Colors.secondaryBackground
                LinearGradient(
                    colors: [Color(hex: "2D3436"), Color(hex: "121212")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [Theme.Colors.mint.opacity(0.1), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 200
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 10)
    }
}
