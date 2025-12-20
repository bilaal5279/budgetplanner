import SwiftUI

struct OnboardingPaywallView: View {
    @Binding var isCompleted: Bool
    
    // Toggle State
    @State private var trialEnabled = true
    
    // Close Button State
    @State private var showCloseButton = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Unlock Full Access")
                    .font(Theme.Fonts.display(24))
                    .foregroundStyle(Theme.Colors.primaryText)
                    .padding(.top, 40)
                    .padding(.bottom, 8)
                
                Text("Start your journey to financial freedom.")
                    .font(Theme.Fonts.body(15))
                    .foregroundStyle(Theme.Colors.secondaryText)
                    .padding(.bottom, 30)
                
                // Toggle Section
                HStack {
                    Text("Enable Free Trial")
                        .font(Theme.Fonts.body(16).weight(.medium))
                        .foregroundStyle(Theme.Colors.primaryText)
                    Spacer()
                    Toggle("", isOn: $trialEnabled)
                        .labelsHidden()
                        .tint(Theme.Colors.mint)
                }
                .padding()
                .background(Theme.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                
                // Plan Card
                // Logic: If trialEnabled, show Weekly with Trial. If disabled, show Annual without Trial.
                VStack(spacing: 16) {
                    if trialEnabled {
                        // Weekly + Trial
                        PlanCard(
                            title: "Weekly Plan",
                            price: "$4.99 / week",
                            trial: "3 Days Free Trial",
                            isSelected: true, // Always selected in this state
                            tag: "Most Flexible"
                        )
                    } else {
                        // Annual (No Trial)
                        PlanCard(
                            title: "Annual Plan",
                            price: "$39.99 / year",
                            trial: "No Free Trial",
                            isSelected: true, // Always selected in this state
                            tag: "Best Value"
                        )
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Features
                VStack(spacing: 12) {
                   OnboardingFeatureRow(text: "Unlimited Accounts")
                   OnboardingFeatureRow(text: "Advanced AI Insights")
                   OnboardingFeatureRow(text: "Cloud Sync & Backup")
                   OnboardingFeatureRow(text: "CSV Exports")
                }
                .padding(.bottom, 32)
                
                // CTA Button
                Button {
                    // Logic would go to In-App Purchase here
                    // For now, it completes onboarding
                    // But in a real app, only successful purchase/restore would complete it.
                    // The user asked for "Unlock" via the X button mainly, but usually this button also works.
                    // For safety, let's keep it as a "mock" purchase that just closes.
                    completeOnboarding()
                } label: {
                    VStack(spacing: 4) {
                        Text(trialEnabled ? "Start Free Trial" : "Continue")
                            .font(Theme.Fonts.body(18).weight(.bold))
                        
                        if trialEnabled {
                            Text("then $4.99/week")
                                .font(Theme.Fonts.body(12))
                                .opacity(0.8)
                        }
                    }
                    .foregroundStyle(Theme.Colors.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Theme.Colors.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // Terms
                HStack(spacing: 16) {
                    Text("Terms")
                    Text("Privacy")
                    Text("Restore")
                }
                .font(.caption)
                .foregroundStyle(Theme.Colors.secondaryText)
                .padding(.bottom, 20)
            }
            
            // X Button (Delayed Unlock)
            if showCloseButton {
                Button {
                    completeOnboarding()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.Colors.secondaryText)
                        .padding(12)
                        .background(Theme.Colors.secondaryBackground)
                        .clipShape(Circle())
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
                .transition(.opacity)
            }
        }
        .onAppear {
            // Unlock X button after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    showCloseButton = true
                }
            }
        }
    }
    
    private func completeOnboarding() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            isCompleted = true
        }
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// Plan Card Component
struct PlanCard: View {
    let title: String
    let price: String
    let trial: String
    let isSelected: Bool
    let tag: String?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(Theme.Fonts.body(18).weight(.semibold))
                    .foregroundStyle(Theme.Colors.primaryText)
                
                Text(price)
                    .font(Theme.Fonts.display(24))
                    .foregroundStyle(Theme.Colors.mint)
                
                Text(trial)
                    .font(Theme.Fonts.body(14))
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Theme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Theme.Colors.mint : Color.clear, lineWidth: 2)
            )
            
            if let tag = tag {
                Text(tag)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.Colors.mint)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .offset(x: -12, y: 12)
            }
        }
    }
}
