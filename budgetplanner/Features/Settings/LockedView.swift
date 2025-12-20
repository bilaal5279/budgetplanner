import SwiftUI

struct LockedView: View {
    @StateObject private var biometricManager = BiometricManager.shared
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Theme.Colors.mint)
                    .padding(40)
                    .background(Theme.Colors.mint.opacity(0.1))
                    .clipShape(Circle())
                
                Text("PocketWealth is Locked")
                    .font(Theme.Fonts.display(24))
                    .foregroundStyle(Theme.Colors.primaryText)
                
                Button {
                    biometricManager.authenticate()
                } label: {
                    Text("Unlock")
                        .font(Theme.Fonts.body(18).weight(.semibold))
                        .foregroundStyle(Theme.Colors.background)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Theme.Colors.primaryText)
                        .clipShape(Capsule())
                }
            }
        }
        .onAppear {
            biometricManager.authenticate()
        }
    }
}
