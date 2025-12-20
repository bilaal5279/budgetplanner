import SwiftUI
import RevenueCat

// MARK: - Premium Paywall (Blueprint Theme)
struct OnboardingPaywallView: View {
    @Binding var isCompleted: Bool
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    // Plan State (Default to Weekly/Trial as it's the "Trial" option now)
    @State private var selectedPlan: PlanType = .weekly
    @State private var showCloseButton = false
    @State private var countdownValue = 0.0
    @State private var showAlert = false
    
    enum PlanType {
        case weekly
        case yearly
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            GridBackground()
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(Theme.Colors.mint)
                        Text("PREMIUM ACCESS")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.Colors.mint)
                            .tracking(2)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Theme.Colors.mint.opacity(0.1))
                    .clipShape(Capsule())
                    
                    Text("Unlock Full\nPotential")
                        .font(Theme.Fonts.display(40))
                        .foregroundStyle(Theme.Colors.primaryText)
                        .lineSpacing(-4)
                    
                    Text("Join 50,000+ users building their financial future.")
                        .font(Theme.Fonts.body(15))
                        .foregroundStyle(Theme.Colors.secondaryText)
                    
                    // Benefits List (Premium Emoji Style)
                    VStack(alignment: .leading, spacing: 16) {
                        BenefitRow(emoji: "🏦", text: "Unlimited Accounts & Wallets")
                        BenefitRow(emoji: "📊", text: "Advanced Analytics & Charts")
                        BenefitRow(emoji: "☁️", text: "Cloud Sync & CSV Export")
                        BenefitRow(emoji: "🏷️", text: "Unlimited Custom Categories")
                        BenefitRow(emoji: "🔒", text: "Face ID & App Lock")
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 60)
                
                Spacer()
                
                // Content Section
                if let offering = subscriptionManager.currentOffering {
                    VStack(spacing: 24) {
                        
                        // Specific Plan Cards (Vertical Stack)
                        VStack(spacing: 16) {
                            // Weekly Card (HAS TRIAL)
                            if let weeklyPackage = offering.package(identifier: "$rc_weekly") {
                                BlueprintPlanCard(
                                    title: "Weekly Plan",
                                    price: weeklyPackage.storeProduct.localizedPriceString,
                                    subtitle: "/ week",
                                    badge: "3 DAY TRIAL",
                                    isSelected: selectedPlan == .weekly,
                                    onTap: { selectedPlan = .weekly }
                                )
                            }
                            
                            // Yearly Card (NO TRIAL)
                            if let yearlyPackage = offering.package(identifier: "$rc_annual") {
                                BlueprintPlanCard(
                                    title: "Yearly Plan",
                                    price: yearlyPackage.storeProduct.localizedPriceString,
                                    subtitle: "/ year",
                                    badge: nil, // Removed badge
                                    isSelected: selectedPlan == .yearly,
                                    onTap: { selectedPlan = .yearly }
                                )
                            }
                        }
                        
                        // Trial Toggle (Moved Below Plans)
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Enable Free Trial")
                                    .font(Theme.Fonts.body(16).weight(.medium))
                                    .foregroundStyle(Theme.Colors.primaryText)
                                Text("No payment required today, cancel anytime.") // Updated Text
                                    .font(Theme.Fonts.body(12))
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { selectedPlan == .weekly },
                                set: { if $0 { selectedPlan = .weekly } else { selectedPlan = .yearly } }
                            ))
                            .labelsHidden()
                            .tint(Theme.Colors.mint)
                        }
                        .padding()
                        .background(
                            ZStack {
                                Theme.Colors.secondaryBackground.opacity(0.3)
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Theme.Colors.secondaryText.opacity(0.1), lineWidth: 1)
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    
                    // CTA Button
                    Button {
                        purchaseSelectedPlan()
                    } label: {
                        VStack(spacing: 4) {
                            if subscriptionManager.isLoading {
                                ProgressView()
                                    .tint(Theme.Colors.background)
                            } else {
                                Text(selectedPlan == .weekly ? "Start 3-Day Free Trial" : "Subscribe Now")
                                    .font(Theme.Fonts.body(18).weight(.bold))
                                
                                // Dynamic Subtext
                                if selectedPlan == .weekly, let price = offering.package(identifier: "$rc_weekly")?.storeProduct.localizedPriceString {
                                    Text("then \(price)/week")
                                        .font(Theme.Fonts.body(12))
                                        .opacity(0.8)
                                } else if let price = offering.package(identifier: "$rc_annual")?.storeProduct.localizedPriceString {
                                    Text("Just \(price)/year")
                                        .font(Theme.Fonts.body(12))
                                        .opacity(0.8)
                                }
                            }
                        }
                        .foregroundStyle(Theme.Colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.Colors.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.Colors.primaryText.opacity(0.3), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .disabled(subscriptionManager.isLoading)
                } else {
                    // Loading State for Offerings
                    VStack {
                        ProgressView()
                            .tint(Theme.Colors.mint)
                        Text("Loading offers...")
                            .font(Theme.Fonts.body(14))
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                    .frame(height: 300)
                }
                
                // Terms
                HStack(spacing: 16) {
                    Link("Terms", destination: URL(string: "https://digitalsprout.org/pocketwealth/terms-of-service")!)
                    Link("Privacy", destination: URL(string: "https://digitalsprout.org/pocketwealth/privacy-policy")!)
                    Button("Restore") {
                        restorePurchases()
                    }
                }
                .font(.caption)
                .foregroundStyle(Theme.Colors.secondaryText)
                .padding(.bottom, 20)
            }
            
            // Close Button Area (Loader -> X)
            ZStack {
                if showCloseButton {
                    Button {
                        completeOnboarding()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.Colors.background) // Invert for high contrast
                            .padding(12)
                            .background(Theme.Colors.primaryText) // Max contrast (Black light / White dark)
                            .clipShape(Circle())
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Loading Circle
                    Circle()
                        .trim(from: 0, to: countdownValue)
                        .stroke(Theme.Colors.primaryText, lineWidth: 3) // Thicker and High Contrast
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                        .padding(8)
                        .transition(.opacity)
                }
            }
            .padding(.top, 60) // Safe area
            .padding(.trailing, 24)
        }
        .onAppear {
            subscriptionManager.fetchOfferings()
            
            // Animate Countdown
            withAnimation(.linear(duration: 5.0)) {
                countdownValue = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation(.spring()) {
                    showCloseButton = true
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(subscriptionManager.errorMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: subscriptionManager.isPremium) { oldValue, newValue in
            if newValue {
                completeOnboarding()
            }
        }
        .onChange(of: subscriptionManager.errorMessage) { oldValue, newValue in
            if newValue != nil {
                showAlert = true
            }
        }
        .interactiveDismissDisabled(!showCloseButton)
    }
    
    private func purchaseSelectedPlan() {
        guard let offering = subscriptionManager.currentOffering else { return }
        
        let packageID = selectedPlan == .weekly ? "$rc_weekly" : "$rc_annual"
        if let package = offering.package(identifier: packageID) {
            subscriptionManager.purchase(package: package) { success in
                if success {
                    completeOnboarding()
                }
            }
        }
    }
    
    // Updated Logic: Standard Restore (Not linked to completion unless successful)
    private func restorePurchases() {
        subscriptionManager.restorePurchases { success in
            if success {
                completeOnboarding()
            } else {
                // Error handled by SubscriptionManager publishing msg
            }
        }
    }
    
    private func completeOnboarding() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        withAnimation { isCompleted.toggle() }
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// MARK: - Components
// MARK: - Components
struct BlueprintPlanCard: View {
    let title: String
    let price: String
    let subtitle: String
    var badge: String? = nil
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Radio/Toggle Indicator
                ZStack {
                    Capsule()
                        .fill(isSelected ? Theme.Colors.mint : Theme.Colors.secondaryText.opacity(0.1))
                        .frame(width: 44, height: 26)
                    
                    Circle()
                        .fill(Theme.Colors.background)
                        .frame(width: 20, height: 20)
                        .shadow(radius: 1)
                        .offset(x: isSelected ? 8 : -8)
                }
                .animation(.spring(response: 0.3), value: isSelected)
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(Theme.Fonts.body(16).weight(.bold))
                            .foregroundStyle(Theme.Colors.primaryText)
                        
                        if let badgeText = badge {
                            Text(badgeText)
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.Colors.mint)
                                .foregroundStyle(Theme.Colors.background)
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("\(price) \(subtitle)")
                        .font(Theme.Fonts.body(14))
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
                
                Spacer()
                
                // Price (Big on right? Or just keep in subtitle?)
                // Let's keep it simple as requested: "horizontal and on different rows"
            }
            .padding(16)
            .background(
                ZStack {
                    Theme.Colors.secondaryBackground.opacity(0.6)
                    
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? Theme.Colors.mint : Theme.Colors.secondaryText.opacity(0.1),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.01 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct BenefitRow: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.mint.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Text(emoji)
                    .font(.system(size: 18))
            }
            
            Text(text)
                .font(Theme.Fonts.body(16))
                .foregroundStyle(Theme.Colors.primaryText)
        }
    }
}
