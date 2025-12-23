import SwiftUI

struct CustomKeypad: View {
    @Binding var input: String
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let keys: [String] = [
        "1", "2", "3",
        "4", "5", "6",
        "7", "8", "9",
        ".", "0", "delete.left"
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) { // Increased spacing
            ForEach(keys, id: \.self) { key in
                KeypadButton(key: key) {
                    handleKeyPress(key)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func handleKeyPress(_ key: String) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
        
        if key == "delete.left" {
            if !input.isEmpty {
                input.removeLast()
            }
        } else {
            // Prevent multiple decimals
            if key == "." && input.contains(".") { return }
            // Max length
            if input.count < 9 {
                input.append(key)
            }
        }
    }
}

struct KeypadButton: View {
    let key: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 14) // Increased radius
                    .fill(Theme.Colors.secondaryBackground.opacity(0.3))
                
                if key == "delete.left" {
                    Image(systemName: key)
                        .font(.title3) // Larger icon
                        .foregroundStyle(Theme.Colors.primaryText)
                } else {
                    Text(key)
                        .font(Theme.Fonts.display(24)) // Larger text
                        .foregroundStyle(Theme.Colors.primaryText)
                }
            }
            .frame(height: 46) // Compact but usable
        }
        .buttonStyle(KeypadButtonStyle())
    }
}

struct KeypadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
