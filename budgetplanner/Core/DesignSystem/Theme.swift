import SwiftUI
import UIKit

struct Theme {
    struct Colors {
        // Adaptive Colors
        static let background = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "121212") : UIColor(hex: "F2F2F7")
        })
        
        static let secondaryBackground = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "1C1C1E") : UIColor(hex: "FFFFFF")
        })
        
        static let primaryText = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        })
        
        static let secondaryText = Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .systemGray : .systemGray2
        })
        
        // Brand Colors (Dynamic)
        static var mint: Color {
            let saved = UserDefaults.standard.string(forKey: "appAccent") ?? "Mint"
            return AppAccent(rawValue: saved)?.color ?? Color(hex: "00C48C")
        }
        
        static var coral: Color { Color(hex: "FF6B6B") } // Keep coral constant or make secondary?
        static let glass = Material.ultraThin
    }
    
    enum AppAppearance: String, CaseIterable, Identifiable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        var id: String { rawValue }
    }
    
    enum AppAccent: String, CaseIterable, Identifiable {
        case mint = "Mint"
        case blue = "Blue"
        case orange = "Orange"
        case pink = "Pink"
        case purple = "Purple"
        
        var id: String { rawValue }
        
        var color: Color {
            switch self {
            case .mint: return Color(hex: "00C48C")
            case .blue: return Color(hex: "54A0FF")
            case .orange: return Color(hex: "FF9F43")
            case .pink: return Color(hex: "FF9FF3")
            case .purple: return Color(hex: "5F27CD")
            }
        }
    }
    
    struct Fonts {
        static func display(_ size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
        
        static func body(_ size: CGFloat) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue:  CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
