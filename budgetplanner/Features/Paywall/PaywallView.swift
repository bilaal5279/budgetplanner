import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(colors: [Theme.Colors.mint, Theme.Colors.coral], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .shadow(color: Theme.Colors.mint.opacity(0.5), radius: 20)
                
                VStack(spacing: 12) {
                    Text("PocketWealth Pro")
                        .font(Theme.Fonts.display(32))
                        .foregroundStyle(Theme.Colors.primaryText)
                    
                    Text("Unlock the full potential of your finances.")
                        .font(Theme.Fonts.body(16))
                        .foregroundStyle(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                
                // Features
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced Analytics")
                    FeatureRow(icon: "square.and.arrow.up", text: "CSV Data Export")
                    FeatureRow(icon: "creditcard.fill", text: "Unlimited Accounts")
                    FeatureRow(icon: "icloud.fill", text: "Cloud Sync")
                }
                .padding(30)
                .background(Theme.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                Spacer()
                
                // CTA
                Button {
                    // Purchase Logic
                    dismiss()
                } label: {
                    Text("Unlock Lifetime ($4.99)")
                        .font(Theme.Fonts.display(18))
                        .foregroundStyle(Theme.Colors.background)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Theme.Colors.mint, Theme.Colors.coral], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
                
                Button("Restore Purchases") {
                    // Restore Logic
                }
                .font(Theme.Fonts.body(14))
                .foregroundStyle(Theme.Colors.secondaryText)
                .padding(.bottom)
            }
            .padding()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Theme.Colors.mint)
                .frame(width: 30)
            
            Text(text)
                .font(Theme.Fonts.body(16))
                .foregroundStyle(Theme.Colors.primaryText)
        }
    }
}
