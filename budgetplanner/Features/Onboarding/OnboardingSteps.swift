import SwiftUI

// MARK: - Blueprint Background
struct GridBackground: View {
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            // Technical Grid
            Canvas { context, size in
                context.stroke(
                    Path { path in
                        let step: CGFloat = 40
                        // Vertical lines
                        for x in stride(from: 0, to: size.width, by: step) {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        }
                        // Horizontal lines
                        for y in stride(from: 0, to: size.height, by: step) {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                        }
                    },
                    with: .color(Theme.Colors.secondaryText.opacity(0.1)),
                    lineWidth: 0.5
                )
            }
            .ignoresSafeArea()
            
            // Vignette for focus
            RadialGradient(
                colors: [Color.clear, Theme.Colors.background],
                center: .center,
                startRadius: 200,
                endRadius: 600
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - 1. Welcome View (The Blueprint)
struct WelcomeView: View {
    var onNext: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            GridBackground()
            
            VStack(spacing: 0) {
                // MARK: - Top Typography
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "compass.drawing") // Technical icon
                            .foregroundStyle(Theme.Colors.mint)
                    
                        Text("EST. 2025")
                            .font(Theme.Fonts.body(12).weight(.bold))
                            .tracking(2)
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                    .padding(.bottom, 4)
                    
                    Text("DESIGN YOUR")
                        .font(Theme.Fonts.body(14).weight(.bold))
                        .tracking(4)
                        .foregroundStyle(Theme.Colors.secondaryText)
                    
                    Text("Financial\nFuture")
                        .font(Theme.Fonts.display(44))
                        .foregroundStyle(Theme.Colors.primaryText)
                        .lineSpacing(-4)
                        .minimumScaleFactor(0.3)
                        .fixedSize(horizontal: false, vertical: true)
                        .overlay(
                            // Decoration Line
                            Rectangle()
                                .fill(Theme.Colors.mint)
                                .frame(width: 60, height: 4)
                                .offset(x: -60, y: 20),
                            alignment: .bottomTrailing
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 10) // Minimal top padding
                .layoutPriority(1) // Keep header visible
                
                Spacer()
                
                // MARK: - Hero Section
                ZStack {
                    // Crosshair Decorations
                    ZStack {
                        Rectangle().frame(width: 1, height: 400)
                        Rectangle().frame(width: 300, height: 1)
                        Circle().strokeBorder(lineWidth: 1).frame(width: 250, height: 250)
                    }
                    .foregroundStyle(Theme.Colors.secondaryText.opacity(0.1))
                    
                    // Main Image
                    Image(colorScheme == .dark ? "onboarding_hero_dark" : "onboarding_hero")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 300, maxHeight: 400) // Constrain max size
                        .blendMode(colorScheme == .dark ? .normal : .multiply) 
                        .offset(y: isAnimating ? -10 : 5)
                        .animation(
                            .easeInOut(duration: 4.0).repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                }
                .padding(.vertical, 10)
                
                Spacer()
                
                // MARK: - Technical CTA
                Button(action: onNext) {
                    HStack(spacing: 16) {
                        Text("Start Building")
                            .font(Theme.Fonts.body(18).weight(.semibold))
                            .tracking(1)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(Theme.Colors.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        ZStack {
                            Theme.Colors.background.opacity(0.8) // Glass base
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Theme.Colors.secondaryText.opacity(0.2), lineWidth: 1)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 30) // Reduced from 50
                .padding(.bottom, 20) // Safe area buffer
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - 2. Blueprint Question View (The Spec Sheet)
struct QuestionView: View {
    let question: String
    let options: [String]
    var onSelect: (String) -> Void
    
    @State private var selectedOption: String? // Manual selection state
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            GridBackground()
            
            HStack(spacing: 0) {
                // Left Margin Guide
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Theme.Colors.secondaryText.opacity(0.1))
                        .frame(width: 1)
                        .padding(.leading, 31)
                    Spacer()
                }
                .frame(width: 32)
                
                // Main Content
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Technical Header
                    HStack(spacing: 12) {
                        Text("STEP 01 // 03")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.Colors.mint)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.Colors.mint.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Rectangle()
                            .fill(Theme.Colors.secondaryText.opacity(0.1))
                            .frame(height: 1)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 24)
                    
                    // Question
                    Text(question)
                        .font(Theme.Fonts.display(32))
                        .foregroundStyle(Theme.Colors.primaryText)
                        .lineSpacing(-2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 40)
                        
                    // Options List
                    VStack(spacing: 16) {
                        ForEach(Array(zip(options.indices, options)), id: \.1) { index, option in
                            BlueprintOptionRow(
                                number: String(format: "%02d", index + 1),
                                text: option,
                                isSelected: selectedOption == option,
                                onTap: { 
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedOption = option 
                                    }
                                }
                            )
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .animation(
                                .easeOut(duration: 0.4).delay(Double(index) * 0.1),
                                value: showContent
                            )
                        }
                    }
                    
                    Spacer()
                    
                    // Next Button (Manual Advance)
                    if let selected = selectedOption {
                        Button(action: { onSelect(selected) }) {
                            HStack {
                                Text("Next Step")
                                    .font(Theme.Fonts.body(18).weight(.bold))
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(Theme.Colors.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                ZStack {
                                    Theme.Colors.background.opacity(0.9)
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Theme.Colors.mint, lineWidth: 1)
                                }
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .shadow(color: Theme.Colors.mint.opacity(0.2), radius: 15, x: 0, y: 5)
                        }
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.trailing, 32)
                .padding(.leading, 24)
            }
        }
        .onAppear {
            showContent = true
        }
    }
}

// MARK: - Blueprint Option Component
// MARK: - Blueprint Option Component
struct BlueprintOptionRow: View {
    let number: String
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Mono Index
                Text(number)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(isSelected ? Theme.Colors.mint : Theme.Colors.secondaryText)
                    .padding(12)
                    .background(
                        Group {
                            if isSelected { Theme.Colors.mint.opacity(0.1) }
                            else { Theme.Colors.secondaryText.opacity(0.05) }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text(text)
                    .font(Theme.Fonts.body(16).weight(isSelected ? .semibold : .medium))
                    .foregroundStyle(Theme.Colors.primaryText)
                
                Spacer()
                
                // Selection Indicator
                Circle()
                    .strokeBorder(
                        isSelected ? Theme.Colors.mint : Theme.Colors.secondaryText.opacity(0.2),
                        lineWidth: 1.5
                    )
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Theme.Colors.mint)
                            .frame(width: 10, height: 10)
                            .scaleEffect(isSelected ? 1 : 0)
                    )
            }
            .padding(16)
            .background(
                ZStack {
                    Theme.Colors.background
                    
                    // Technical Border
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? Theme.Colors.mint : Theme.Colors.secondaryText.opacity(0.15),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isSelected ? 1.02 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 3. Blueprint Analyzing View (Friendly Premium)
struct AnalyzingView: View {
    var onFinished: () -> Void
    
    @State private var statusText: String = "Personalizing your plan..."
    @State private var isBreathing = false
    @State private var showRipple1 = false
    @State private var showRipple2 = false
    
    var body: some View {
        ZStack {
            GridBackground()
            
            VStack(spacing: 50) {
                Spacer()
                
                // 1. Magical Central Visual
                ZStack {
                    // Ripples
                    Circle()
                        .stroke(Theme.Colors.mint.opacity(0.3), lineWidth: 1)
                        .frame(width: 100, height: 100)
                        .scaleEffect(showRipple1 ? 3 : 1)
                        .opacity(showRipple1 ? 0 : 0.5)
                        .animation(.easeOut(duration: 2.5).repeatForever(autoreverses: false), value: showRipple1)
                    
                    Circle()
                        .stroke(Theme.Colors.mint.opacity(0.2), lineWidth: 1)
                        .frame(width: 100, height: 100)
                        .scaleEffect(showRipple2 ? 3 : 1)
                        .opacity(showRipple2 ? 0 : 0.4)
                        .animation(.easeOut(duration: 2.5).repeatForever(autoreverses: false).delay(1.2), value: showRipple2)
                    
                    // Glow
                    Circle()
                        .fill(Theme.Colors.mint.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .scaleEffect(isBreathing ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isBreathing)
                    
                    // Icon
                    Circle()
                        .fill(Theme.Colors.background)
                        .frame(width: 100, height: 100)
                        .shadow(color: Theme.Colors.mint.opacity(0.2), radius: 20, x: 0, y: 10)
                        .overlay(
                            Image(systemName: "sparkles")
                                .font(.system(size: 40))
                                .foregroundStyle(Theme.Colors.mint)
                                .scaleEffect(isBreathing ? 1.1 : 0.9)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isBreathing)
                        )
                }
                
                // 2. Friendly Status Text
                VStack(spacing: 12) {
                    Text(statusText)
                        .font(Theme.Fonts.display(24))
                        .foregroundStyle(Theme.Colors.primaryText)
                        .multilineTextAlignment(.center)
                        // Smooth text transition
                        .contentTransition(.numericText(countsDown: false)) 
                        .animation(.snappy, value: statusText)
                    
                    Text("Just a moment while we tailor\nyour financial blueprint.")
                        .font(Theme.Fonts.body(16))
                        .foregroundStyle(Theme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)
                
                Spacer()
            }
        }
        .onAppear {
            startFriendlySequence()
        }
    }
    
    private func startFriendlySequence() {
        showRipple1 = true
        showRipple2 = true
        isBreathing = true
        
        // Friendly Sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            statusText = "Optimization in progress..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            statusText = "Finalizing your strategy..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
            onFinished()
        }
    }
}

// MARK: - 4. Blueprint Plan Reveal (The Report)
struct PlanRevealView: View {
    var onContinue: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            GridBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // 1. Report Header
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Theme.Colors.mint)
                                .frame(width: 8, height: 8)
                                .shadow(color: Theme.Colors.mint, radius: 5)
                            
                            Text("ANALYSIS COMPLETE")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(Theme.Colors.mint)
                                .tracking(2)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Theme.Colors.mint.opacity(0.1))
                        .clipShape(Capsule())
                        .padding(.top, 40)
                        
                        Text("Your Financial\nBlueprint")
                            .font(Theme.Fonts.display(40))
                            .foregroundStyle(Theme.Colors.primaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(-4)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.6), value: showContent)
                    
                    // 2. Hero Insight: Growth Potential
                    BlueprintCard {
                        VStack(spacing: 20) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("SAVINGS POTENTIAL")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                        .tracking(1)
                                    
                                    Text("+ 25%")
                                        .font(Theme.Fonts.display(32))
                                        .foregroundStyle(Theme.Colors.mint)
                                }
                                Spacer()
                                
                                Image(systemName: "chart.xyaxis.line")
                                    .foregroundStyle(Theme.Colors.mint)
                                    .font(.title2)
                                    .padding(8)
                                    .background(Theme.Colors.mint.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            // Beautiful Area Chart
                            GrowthAreaChart()
                                .frame(height: 120)
                            
                            Text("Based on your inputs, you could save an extra **25%** of your income by optimizing impulse spending.")
                                .font(Theme.Fonts.body(14))
                                .foregroundStyle(Theme.Colors.secondaryText)
                                .lineSpacing(4)
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
                    
                    // 3. Secondary Insights Grid
                    HStack(spacing: 16) {
                        // Card A: Success Rate
                        BlueprintCard {
                            VStack(alignment: .leading, spacing: 12) {
                                RingChart(percentage: 0.87)
                                    .frame(width: 40, height: 40)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("87%")
                                        .font(Theme.Fonts.display(24))
                                        .foregroundStyle(Theme.Colors.primaryText)
                                    
                                    Text("Success Rate")
                                        .font(Theme.Fonts.body(13))
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                }
                            }
                        }
                        
                        // Card B: Efficiency
                        BlueprintCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Image(systemName: "hourglass")
                                    .foregroundStyle(Theme.Colors.mint)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("3x")
                                        .font(Theme.Fonts.display(24))
                                        .foregroundStyle(Theme.Colors.primaryText)
                                    
                                    Text("Faster Growth")
                                        .font(Theme.Fonts.body(13))
                                        .foregroundStyle(Theme.Colors.secondaryText)
                                }
                            }
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 40)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: showContent)
                    
                    Spacer(minLength: 40)
                    
                    // 4. Reveal Action
                    Button(action: onContinue) {
                        HStack(spacing: 16) {
                            Text("Unlock Full Access")
                                .font(Theme.Fonts.body(18).weight(.semibold))
                                .tracking(1)
                            
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundStyle(Theme.Colors.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Theme.Colors.primaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.Colors.primaryText.opacity(0.3), radius: 20, x: 0, y: 10)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 40)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: showContent)
                }
                .padding(.horizontal, 24)
            }
        }
        .onAppear {
            showContent = true
        }
    }
}

// MARK: - Components

struct BlueprintCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                ZStack {
                    Theme.Colors.secondaryBackground.opacity(0.6) // Glassy
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Theme.Colors.secondaryText.opacity(0.1), lineWidth: 1)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
    }
}

struct GrowthAreaChart: View {
    var body: some View {
        Canvas { context, size in
            // Gradient Fill
            let path = Path { p in
                p.move(to: CGPoint(x: 0, y: size.height))
                p.addLine(to: CGPoint(x: 0, y: size.height * 0.8))
                p.addCurve(
                    to: CGPoint(x: size.width, y: size.height * 0.1),
                    control1: CGPoint(x: size.width * 0.4, y: size.height * 0.8),
                    control2: CGPoint(x: size.width * 0.6, y: size.height * 0.1)
                )
                p.addLine(to: CGPoint(x: size.width, y: size.height))
                p.closeSubpath()
            }
            
            context.fill(
                path,
                with: .linearGradient(
                    Gradient(colors: [Theme.Colors.mint.opacity(0.4), Theme.Colors.mint.opacity(0.0)]),
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: size.height)
                )
            )
            
            // Stroke Line
            let linePath = Path { p in
                p.move(to: CGPoint(x: 0, y: size.height * 0.8))
                p.addCurve(
                    to: CGPoint(x: size.width, y: size.height * 0.1),
                    control1: CGPoint(x: size.width * 0.4, y: size.height * 0.8),
                    control2: CGPoint(x: size.width * 0.6, y: size.height * 0.1)
                )
            }
            
            context.stroke(
                linePath,
                with: .color(Theme.Colors.mint),
                lineWidth: 3
            )
        }
    }
}

struct RingChart: View {
    let percentage: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.secondaryText.opacity(0.1), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: percentage)
                .stroke(Theme.Colors.mint, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// Helper Row
struct OnboardingFeatureRow: View {
    let text: String
    var fontSize: CGFloat = 15
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.Colors.mint)
                .font(.system(size: fontSize + 2)) // Scale icon slightly with text
            
            Text(text)
                .font(Theme.Fonts.body(fontSize))
                .foregroundStyle(Theme.Colors.primaryText)
        }
    }
}
