import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) var openURL
    
    @State private var appearAnimation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "leaf.fill") // App Logo Placeholder
                        .font(.system(size: 60))
                        .foregroundStyle(Theme.Colors.mint)
                        .padding(24)
                        .background(
                            Circle()
                                .fill(Theme.Colors.mint.opacity(0.1))
                        )
                        .shadow(color: Theme.Colors.mint.opacity(0.2), radius: 20)
                    
                    VStack(spacing: 8) {
                        Text("PocketWealth")
                            .font(Theme.Fonts.display(32))
                            .foregroundStyle(Theme.Colors.primaryText)
                        
                        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                            .font(Theme.Fonts.body(14))
                            .foregroundStyle(Theme.Colors.secondaryText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Theme.Colors.secondaryBackground)
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 40)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 20)
                
                // Story Section
                VStack(alignment: .leading, spacing: 24) {
                    Text("Our Story")
                        .font(Theme.Fonts.display(24))
                        .foregroundStyle(Theme.Colors.primaryText)
                    
                    Text("PocketWealth was born from a simple belief: managing your money shouldn't feel like a chore. We wanted to build a tool that isn't just a spreadsheet in disguise, but a beautiful companion for your financial journey.")
                        .font(Theme.Fonts.body(16))
                        .foregroundStyle(Theme.Colors.secondaryText)
                        .lineSpacing(6)
                    
                    Text("We believe that clarity brings confidence. By stripping away the noise and focusing on what matters—where your money goes and how it grows—we help you take control of your future, one transaction at a time.")
                        .font(Theme.Fonts.body(16))
                        .foregroundStyle(Theme.Colors.secondaryText)
                        .lineSpacing(6)
                }
                .padding(24)
                .background(Theme.Colors.secondaryBackground.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 30)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: appearAnimation)
                
                // Mission Section
                VStack(alignment: .leading, spacing: 20) {
                    Text("Our Mission")
                        .font(Theme.Fonts.display(24))
                        .foregroundStyle(Theme.Colors.primaryText)
                    
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 16) {
                        MissionRow(icon: "sparkles", text: "Design that delights")
                        MissionRow(icon: "lock.shield", text: "Privacy first, always")
                        MissionRow(icon: "bolt.fill", text: "Speed and simplicity")
                    }
                }
                .padding(.horizontal, 24)
                .opacity(appearAnimation ? 1 : 0)
                .offset(y: appearAnimation ? 0 : 40)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: appearAnimation)
                
                // Team/Company
                VStack(spacing: 8) {
                    Text("Crafted by")
                        .font(Theme.Fonts.body(14))
                        .foregroundStyle(Theme.Colors.secondaryText)
                    
                    Text("Digital Sprout")
                        .font(Theme.Fonts.display(20))
                        .foregroundStyle(Theme.Colors.primaryText)
                    
                    Link(destination: URL(string: "https://digitalsprout.org")!) {
                        Text("Visit Website")
                            .font(Theme.Fonts.body(14))
                            .foregroundStyle(Theme.Colors.mint)
                    }
                    .padding(.top, 4)
                }
                .padding(.top, 24)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: appearAnimation)
                
                // Legal Footer
                VStack(spacing: 16) {
                    Divider()
                        .background(Theme.Colors.secondaryText.opacity(0.2))
                    
                    HStack(spacing: 24) {
                        Link("Privacy Policy", destination: URL(string: "https://digitalsprout.org/pocketwealth/privacy-policy")!)
                        Link("Terms of Service", destination: URL(string: "https://digitalsprout.org/pocketwealth/terms-of-service")!)
                    }
                    .font(.caption)
                    .foregroundStyle(Theme.Colors.secondaryText)
                    
                    Text("Made with ❤️ for you")
                        .font(.caption2)
                        .foregroundStyle(Theme.Colors.secondaryText.opacity(0.5))
                }
                .padding(.vertical, 32)
                .opacity(appearAnimation ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: appearAnimation)
            }
        }
        .background(Theme.Colors.background)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appearAnimation = true
            }
        }
    }
}

struct MissionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        GridRow {
            Image(systemName: icon)
                .foregroundStyle(Theme.Colors.mint)
                .frame(width: 24)
            Text(text)
                .font(Theme.Fonts.body(16))
                .foregroundStyle(Theme.Colors.primaryText)
        }
    }
}
