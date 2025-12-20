import SwiftUI

struct AppLockSettingsView: View {
    @StateObject private var biometricManager = BiometricManager.shared
    @StateObject var subscriptionManager: SubscriptionManager
    @Binding var showPaywall: Bool
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $biometricManager.useFaceID) {
                    HStack {
                        Image(systemName: "faceid")
                            .foregroundStyle(Theme.Colors.mint)
                            .frame(width: 24)
                        Text("App Lock")
                    }
                }
                .onChange(of: biometricManager.useFaceID) { _, newValue in
                    if newValue && !subscriptionManager.isPremium {
                        biometricManager.useFaceID = false
                        showPaywall = true
                    }
                }
            } footer: {
                Text("When enabled, use Face ID or your device passcode to unlock the app.")
            }
            
            if biometricManager.useFaceID {
                Section {
                    Picker("Require Authentication", selection: $biometricManager.lockTimeout) {
                        ForEach(BiometricManager.LockTimeout.allCases) { timeout in
                            Text(timeout.title).tag(timeout)
                        }
                    }
                } footer: {
                    Text("If you exit the app and return within this time, Face ID will not be required.")
                }
            }
        }
        .navigationTitle("App Lock")
        .navigationBarTitleDisplayMode(.inline)
    }
}
