import SwiftUI
import SwiftData

struct CategorySelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]
    
    let color: Color
    let onSelect: (Category) -> Void
    
    @State private var showingAddCategory = false
    @State private var categoryToEdit: Category?
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 20) {
                    // Add New Button
                    Button {
                        let customCount = categories.filter { $0.isCustom }.count
                        if !subscriptionManager.isPremium && customCount >= 1 {
                             showPaywall = true
                        } else {
                            showingAddCategory = true
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(Theme.Colors.secondaryBackground)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Theme.Colors.primaryText)
                                )
                            
                            Text("New")
                                .font(Theme.Fonts.body(12))
                                .foregroundStyle(Theme.Colors.secondaryText)
                        }
                    }
                    
                    // Categories
                    ForEach(categories) { category in
                        Button {
                            onSelect(category)
                            dismiss()
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: category.colorHex).opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: category.icon)
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color(hex: category.colorHex))
                                }
                                
                                Text(category.name)
                                    .font(Theme.Fonts.body(12))
                                    .foregroundStyle(Theme.Colors.primaryText)
                                    .lineLimit(1)
                            }
                        }
                        .contextMenu {
                            Button("Edit") {
                                categoryToEdit = category // Implement edit if needed, or just delete
                            }
                            Button("Delete", role: .destructive) {
                                modelContext.delete(category)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
            .fullScreenCover(isPresented: $showPaywall) {
                OnboardingPaywallView(isCompleted: $showPaywall)
            }
        }
        .presentationDetents([.medium, .large])
    }
}
