import SwiftUI

// MARK: - Premium Background
struct PremiumBackground: View {
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            // Subtle top-right blob
            GeometryReader { proxy in
                Circle()
                    .fill(Theme.Colors.mint.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .position(x: proxy.size.width, y: 0)
                
                // Bottom-left blob
                Circle()
                    .fill(Theme.Colors.secondaryText.opacity(0.05))
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .position(x: 0, y: proxy.size.height)
            }
        }
    }
}

// MARK: - 1. Welcome View
struct WelcomeView: View {
    var onNext: () -> Void
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Hero Image
                Image("onboarding_hero")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280) // Adjust size as needed
                    .shadow(color: Theme.Colors.mint.opacity(0.2), radius: 20, x: 0, y: 10)
                    .padding(.bottom, 40)
                
                VStack(spacing: 16) {
                    Text("Hey there!\nYou're in the right place.")
                        .font(Theme.Fonts.display(32))
                        .foregroundStyle(Theme.Colors.primaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Text("We'll help you start managing\nyour financial life.")
                        .font(Theme.Fonts.body(18))
                        .foregroundStyle(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button(action: onNext) {
                    Text("Get Started")
                        .font(Theme.Fonts.body(18).weight(.bold))
                        .foregroundStyle(Theme.Colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.Colors.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.Colors.primaryText.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .padding()
        }
    }
}

// MARK: - 2. Generic Question View
struct QuestionView: View {
    let question: String
    let options: [String]
    var onSelect: (String) -> Void
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 24) {
                Text(question)
                    .font(Theme.Fonts.display(28))
                    .foregroundStyle(Theme.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top, 60)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(options, id: \.self) { option in
                            Button(action: { onSelect(option) }) {
                                HStack {
                                    Text(option)
                                        .font(Theme.Fonts.body(18).weight(.medium))
                                        .foregroundStyle(Theme.Colors.primaryText)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(Theme.Colors.secondaryText.opacity(0.5))
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 24)
                                .background(Theme.Colors.secondaryBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Theme.Colors.secondaryText.opacity(0.05), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - 3. Analyzing View
struct AnalyzingView: View {
    @State private var progress: Double = 0.0
    @State private var statusText: String = "Analyzing spending habits..."
    var onFinished: () -> Void
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            VStack(spacing: 32) {
                Spacer()
                
                ZStack {
                    // Pulsing backgrounds
                    Circle()
                        .fill(Theme.Colors.mint.opacity(0.1))
                        .frame(width: 140, height: 140)
                        .scaleEffect(progress > 0.5 ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: progress)
                    
                    Circle()
                        .stroke(Theme.Colors.secondaryBackground, lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Theme.Colors.mint, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: progress)
                }
                
                VStack(spacing: 8) {
                    Text(statusText)
                        .font(Theme.Fonts.body(20).weight(.medium))
                        .foregroundStyle(Theme.Colors.primaryText)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut, value: statusText)
                    
                    Text("Please wait while we build your plan.")
                        .font(Theme.Fonts.body(14))
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
                    
                Spacer()
            }
            .padding()
        }
        .onAppear {
            startFakeAnalysis()
        }
    }
    
    private func startFakeAnalysis() {
        animateProgress(to: 0.3, duration: 1.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            statusText = "Calculating potential savings..."
            animateProgress(to: 0.7, duration: 1.0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            statusText = "Optimizing your budget..."
            animateProgress(to: 1.0, duration: 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            onFinished()
        }
    }
    
    private func animateProgress(to value: Double, duration: TimeInterval) {
        withAnimation(.linear(duration: duration)) {
            progress = value
        }
    }
}

// MARK: - 4. Plan Reveal View
struct PlanRevealView: View {
    var onContinue: () -> Void
    
    var body: some View {
        ZStack {
            PremiumBackground()
            
            ScrollView {
                VStack(spacing: 0) {
                    
                    // Header Content
                    VStack(spacing: 12) {
                        Text("Your Personalized Plan")
                            .font(Theme.Fonts.body(14).weight(.bold))
                            .foregroundStyle(Theme.Colors.mint)
                            .textCase(.uppercase)
                            .padding(.top, 40)
                        
                        Text("Save 25% of your\nmonthly income")
                            .font(Theme.Fonts.display(32))
                            .foregroundStyle(Theme.Colors.primaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 32)
                    
                    // Chart 1: Savings Potential
                    VStack(spacing: 16) {
                        Text("Projected Savings")
                            .font(Theme.Fonts.body(16).weight(.semibold))
                            .foregroundStyle(Theme.Colors.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        SavingsBarChart()
                        
                        Text("On average, our users save 3x more than manual trackers.")
                            .font(Theme.Fonts.body(13))
                            .foregroundStyle(Theme.Colors.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(24)
                    .background(Theme.Colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    Spacer(minLength: 24)
                    
                    // Chart 2: Social Proof / Failure Rate
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            // Ring Chart
                            FailureRateChart()
                                .frame(width: 70, height: 70)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("87% of People")
                                    .font(Theme.Fonts.body(18).weight(.bold))
                                    .foregroundStyle(Theme.Colors.primaryText)
                                
                                Text("return to old habits without a proper system.")
                                    .font(Theme.Fonts.body(14))
                                    .foregroundStyle(Theme.Colors.secondaryText)
                            }
                        }
                        
                        Divider().padding(.vertical, 8)
                        
                        // Feature List
                        VStack(alignment: .leading, spacing: 12) {
                            OnboardingFeatureRow(text: "Automated tracking")
                            OnboardingFeatureRow(text: "Smart budget alerts")
                            OnboardingFeatureRow(text: "Visual financial clarity")
                        }
                    }
                    .padding(24)
                    .background(Theme.Colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 24)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    Spacer(minLength: 40)
                    
                    Button(action: onContinue) {
                        Text("See My Plan")
                            .font(Theme.Fonts.body(18).weight(.bold))
                            .foregroundStyle(Theme.Colors.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Theme.Colors.primaryText)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Theme.Colors.primaryText.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Charts

struct SavingsBarChart: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 32) {
            // Bar 1: Average
            VStack(spacing: 8) {
                Text("Average")
                    .font(Theme.Fonts.body(12))
                    .foregroundStyle(Theme.Colors.secondaryText)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.Colors.secondaryText.opacity(0.2))
                    .frame(width: 40, height: 60)
                
                Text("5%")
                    .font(Theme.Fonts.body(14).weight(.medium))
                    .foregroundStyle(Theme.Colors.secondaryText)
            }
            
            // Bar 2: You
            VStack(spacing: 8) {
                Text("PocketWealth")
                    .font(Theme.Fonts.body(12).weight(.bold))
                    .foregroundStyle(Theme.Colors.mint)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Theme.Colors.mint)
                    .frame(width: 40, height: 140) // Taller to show improvement
                
                Text("25%")
                    .font(Theme.Fonts.body(14).weight(.bold))
                    .foregroundStyle(Theme.Colors.primaryText)
            }
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.01)) // Touch area
    }
}

struct FailureRateChart: View {
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(Theme.Colors.mint.opacity(0.2), lineWidth: 8)
            
            // Progress Circle (Red/Orange for "Failure")
            Circle()
                .trim(from: 0, to: 0.87)
                .stroke(Theme.Colors.coral, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("87%")
                .font(Theme.Fonts.body(16).weight(.bold))
                .foregroundStyle(Theme.Colors.primaryText)
        }
    }
}

// Helper Row
struct OnboardingFeatureRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.Colors.mint)
            Text(text)
                .font(Theme.Fonts.body(15))
                .foregroundStyle(Theme.Colors.primaryText)
        }
    }
}
