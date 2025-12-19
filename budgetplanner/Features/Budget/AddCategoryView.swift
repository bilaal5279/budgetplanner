import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "tag.fill"
    @State private var selectedColor: String = "00C48C" // Mint default
    @State private var budgetLimitString: String = ""
    
    let icons = [
        "tag.fill", "fork.knife", "cup.and.saucer.fill", "cart.fill",
        "car.fill", "tram.fill", "airplane", "house.fill",
        "gamecontroller.fill", "tv.fill", "music.note", "book.fill",
        "cross.case.fill", "pills.fill", "banknote.fill", "gift.fill"
    ]
    
    let colors = [
        "00C48C", // Mint
        "FF6B6B", // Coral
        "54A0FF", // Blue
        "F368E0", // Pink
        "FF9FF3", // Light Purple
        "FECA57", // Yellow
        "FF9F43", // Orange
        "A3CB38"  // Green
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: selectedColor).opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 32))
                                    .foregroundStyle(Color(hex: selectedColor))
                            }
                            
                            TextField("Category Name", text: $name)
                                .font(Theme.Fonts.display(24))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Theme.Colors.primaryText)
                                .submitLabel(.done)
                        }
                        .padding(.top, 20)
                        
                        // Budget Limit
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Monthly Budget Limit")
                                .font(Theme.Fonts.body(14))
                                .foregroundStyle(Theme.Colors.secondaryText)
                                .padding(.horizontal)
                            
                            HStack {
                                Text(CurrencyManager.shared.getSymbol(for: CurrencyManager.shared.currencyCode))
                                    .font(Theme.Fonts.display(24))
                                    .foregroundStyle(Theme.Colors.secondaryText)
                                
                                TextField("0.00", text: $budgetLimitString)
                                    .font(Theme.Fonts.display(24))
                                    .foregroundStyle(Theme.Colors.primaryText)
                                    .keyboardType(.decimalPad)
                            }
                            .padding()
                            .background(Theme.Colors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                        }
                        
                        // Color Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color")
                                .font(Theme.Fonts.body(14))
                                .foregroundStyle(Theme.Colors.secondaryText)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            withAnimation { selectedColor = color }
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Icon Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Icon")
                                .font(Theme.Fonts.body(14))
                                .foregroundStyle(Theme.Colors.secondaryText)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(icons, id: \.self) { icon in
                                    ZStack {
                                        Circle()
                                            .fill(Theme.Colors.secondaryBackground)
                                            .frame(height: 44)
                                        
                                        Image(systemName: icon)
                                            .foregroundStyle(selectedIcon == icon ? Theme.Colors.primaryText : Theme.Colors.secondaryText)
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(Theme.Colors.mint, lineWidth: selectedIcon == icon ? 2 : 0)
                                    )
                                    .onTapGesture {
                                        withAnimation { selectedIcon = icon }
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCategory()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        let limit = Double(budgetLimitString)
        let newCategory = Category(
            name: name,
            icon: selectedIcon,
            colorHex: selectedColor,
            budgetLimit: limit
        )
        modelContext.insert(newCategory)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        dismiss()
    }
}
