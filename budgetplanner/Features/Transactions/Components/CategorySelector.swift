import SwiftUI

struct CategorySelector: View {
    @Binding var selectedCategory: Category?
    let categories: [Category]
    var color: Color = Theme.Colors.mint
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(selectedCategory == category ? color : Theme.Colors.secondaryBackground)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: category.icon)
                                    .font(.system(size: 24))
                                    .foregroundStyle(selectedCategory == category ? .white : Theme.Colors.secondaryText)
                            }
                            // Ring effect for selection
                            .overlay(
                                Circle()
                                    .stroke(color, lineWidth: selectedCategory == category ? 2 : 0)
                                    .scaleEffect(selectedCategory == category ? 1.15 : 1.0)
                                    .opacity(selectedCategory == category ? 0.5 : 0)
                            )
                            
                            Text(category.name)
                                .font(Theme.Fonts.body(12))
                                .foregroundStyle(selectedCategory == category ? Theme.Colors.primaryText : Theme.Colors.secondaryText)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }
}
