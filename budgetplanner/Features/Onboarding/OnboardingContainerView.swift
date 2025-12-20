import SwiftUI

struct OnboardingContainerView: View {
    @Binding var isCompleted: Bool
    
    // 0: Welcome
    // 1: Question 1 (Goal)
    // 2: Question 2 (Spending)
    // 3: Analyzing
    // 4: Plan Reveal
    // 5: Paywall
    @State private var currentStep = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            Theme.Colors.background.ignoresSafeArea()
            
            // Content zIndex 0
            ZStack {
                switch currentStep {
                case 0:
                    WelcomeView {
                        withAnimation { currentStep += 1 }
                    }
                    .transition(.opacity)
                    
                case 1:
                    QuestionView(
                        question: "What is your primary financial goal?",
                        options: ["Save more money", "Track my spending", "Get out of debt", "Stop impulse buying"]
                    ) { _ in
                        withAnimation { currentStep += 1 }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    
                case 2:
                    QuestionView(
                        question: "How much of your income do you save?",
                        options: ["0% - 5%", "5% - 10%", "10% - 20%", "20% +"]
                    ) { _ in
                        withAnimation { currentStep += 1 }
                    }
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                    
                case 3:
                    AnalyzingView {
                        withAnimation { currentStep += 1 }
                    }
                    .transition(.opacity)
                    
                case 4:
                    PlanRevealView {
                        withAnimation { currentStep += 1 }
                    }
                    .transition(.opacity)
                    
                case 5:
                    OnboardingPaywallView(isCompleted: $isCompleted)
                    .transition(.move(edge: .bottom))
                    
                default:
                    EmptyView()
                }
            }
            // Add padding top to content so it doesn't overlap progress bar if needed
            // But WelcomeView likely handles its own spacing.
            
            // Progress Header zIndex 1
            if currentStep < 5 { // Hide on Paywall? Usually displayed until end, but Paywall is "Result". Let's hide it there or keep full? User didn't specify. I'll hide on Paywall for cleaner look.
                 ProgressHeader(totalSteps: 5, currentStep: currentStep)
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct ProgressHeader: View {
    let totalSteps: Int
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentStep ? Theme.Colors.mint : Theme.Colors.secondaryBackground)
                    .frame(height: 4)
                    .animation(.spring(), value: currentStep)
            }
        }
    }
}
