import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image("AppIcon") // Placeholder if asset exists, else system
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 10)
                
                VStack(spacing: 8) {
                    Text("PocketWealth")
                        .font(.title2.bold())
                    Text("Your Personal Finance Companion")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Text("Designed and developed with ❤️ to help you track your finances, visualize your spending trends, and reach your saving goals.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundStyle(Theme.Colors.secondaryText)
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}
