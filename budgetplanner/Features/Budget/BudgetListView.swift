import SwiftUI
import SwiftData

struct BudgetListView: View {
    @Query(sort: \Category.name) private var categories: [Category]
    @Query private var transactions: [Transaction]
    @State private var isPresentingAddCategory = false
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                if categories.isEmpty {
                    ContentUnavailableView("No Budgets", systemImage: "chart.bar.doc.horizontal", description: Text("Create a category to start budgeting."))
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Overall Summary Card
                            BudgetSummaryCard(categories: categories, transactions: transactions)
                            
                            // Category Grid
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(categories) { category in
                                    BudgetGridItem(category: category, spent: calculateSpent(for: category))
                                }
                            }
                            .padding(.bottom, 100)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Budget")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentingAddCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddCategory) {
                AddCategoryView()
            }
        }
    }
    
    private func calculateSpent(for category: Category) -> Double {
        // Simple filter: All time for now, or assume this month
        // For "Premium" feel, let's just sum all transactions for this category that are expenses
        let categoryTransactions = transactions.filter { $0.category == category && $0.type == .expense }
        return categoryTransactions.reduce(0) { $0 + $1.amount }
    }
}

struct BudgetGridItem: View {
    let category: Category
    let spent: Double
    
    var progress: Double {
        guard let limit = category.budgetLimit, limit > 0 else { return 0 }
        return min(spent / limit, 1.0)
    }
    
    var isOverBudget: Bool {
        guard let limit = category.budgetLimit else { return false }
        return spent > limit
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon + Progress Ring
            ZStack {
                // Background Ring
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 6)
                    .frame(width: 60, height: 60)
                
                // Progress Ring
                if let _ = category.budgetLimit {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            isOverBudget ? Theme.Colors.coral : Theme.Colors.mint,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: (isOverBudget ? Theme.Colors.coral : Theme.Colors.mint).opacity(0.5), radius: 5)
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
                
                if let limit = category.budgetLimit {
                    Text("\(String(format: "$%.0f", spent)) / \(String(format: "$%.0f", limit))")
                        .font(Theme.Fonts.body(12))
                        .foregroundStyle(Theme.Colors.secondaryText)
                } else {
                    Text(String(format: "$%.0f", spent))
                        .font(Theme.Fonts.body(12))
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
    }
}

struct BudgetSummaryCard: View {
    let categories: [Category]
    let transactions: [Transaction]
    
    var totalBudget: Double {
        categories.reduce(0) { $0 + ($1.budgetLimit ?? 0) }
    }
    
    var totalSpent: Double {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
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
                    Text(String(format: "$%.2f", totalSpent))
                        .font(Theme.Fonts.display(28))
                        .foregroundStyle(Color.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Budget")
                        .font(Theme.Fonts.body(14))
                        .foregroundStyle(Color.white.opacity(0.7))
                    Text(String(format: "$%.0f", totalBudget))
                        .font(Theme.Fonts.body(18))
                        .foregroundStyle(Color.white.opacity(0.9))
                }
            }
            
            Spacer()
        }
        .padding(24)
        .background(
            ZStack {
                Theme.Colors.secondaryBackground // Fallback
                
                // Dark Gradient
                LinearGradient(
                    colors: [
                        Color(hex: "2D3436"),
                        Color(hex: "121212")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Subtle Accent Splash
                RadialGradient(
                    colors: [Theme.Colors.mint.opacity(0.1), Color.clear],
                    center: .topTrailing,
                    startRadius: 0,
                    endRadius: 200
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 10)
    }
}
