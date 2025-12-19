import SwiftUI
import SwiftData

struct CategoriesSettingsView: View {
    let type: TransactionType
    @Environment(\.modelContext) private var modelContext
    @Query private var allCategories: [Category]
    @Environment(\.dismiss) private var dismiss
    
    // Sheet State
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var newCategoryIcon = "tag.fill"
    @State private var newCategoryColor = Theme.Colors.mint
    
    // Filtered categories based on the passed type
    var displayedCategories: [Category] {
        allCategories.filter { $0.type == type }.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        List {
            ForEach(displayedCategories) { category in
                HStack {
                    Circle()
                        .fill(Color(hex: category.colorHex))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: category.icon)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                    
                    Text(category.name)
                        .font(Theme.Fonts.body(16))
                        .foregroundStyle(Theme.Colors.primaryText)
                    
                    Spacer()
                }
            }
            .onDelete(perform: deleteCategory)
        }
        .navigationTitle("\(type == .expense ? "Expense" : "Income") Categories")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCategory) {
            NavigationStack {
                Form {
                    Section("Details") {
                        TextField("Category Name", text: $newCategoryName)
                        
                        // Simple Icon Picker (Placeholder for now, can be expanded)
                        HStack {
                            Text("Icon")
                            Spacer()
                            Image(systemName: newCategoryIcon)
                        }
                        
                        ColorPicker("Color", selection: $newCategoryColor)
                    }
                }
                .navigationTitle("New Category")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingAddCategory = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            addCategory()
                            showingAddCategory = false
                        }
                        .disabled(newCategoryName.isEmpty)
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func addCategory() {
        let category = Category(
            name: newCategoryName,
            icon: newCategoryIcon,
            colorHex: newCategoryColor.toHex() ?? "00C48C",
            type: type
        )
        modelContext.insert(category)
        
        // Reset
        newCategoryName = ""
        newCategoryIcon = "tag.fill" // default
    }
    
    private func deleteCategory(at offsets: IndexSet) {
        for index in offsets {
            let category = displayedCategories[index]
            // Optional: Check if used?
            modelContext.delete(category)
        }
    }
}
