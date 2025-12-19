import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .add
    
    enum Tab {
        case add, accounts, analysis, budget, settings
    }
    
    var body: some View {
        ZStack {
            // Background
            Theme.Colors.background.ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {

                switch selectedTab {
                case .add:
                    AddTransactionView()
                case .accounts:
                    AccountsView()
                case .analysis:
                    AnalysisView()
                case .budget:
                    BudgetListView()
                case .settings:
                    SettingsView()
                }
                

            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
            
            // Custom Tab Bar Overlay
            VStack {
                Spacer()
                ZStack(alignment: .top) {
                    // Glass Background
                    HStack {
                        TabBarButton(icon: "plus.circle", title: "Add", tab: .add, selectedTab: $selectedTab)
                        TabBarButton(icon: "creditcard", title: "Accounts", tab: .accounts, selectedTab: $selectedTab)
                        TabBarButton(icon: "chart.pie", title: "Analysis", tab: .analysis, selectedTab: $selectedTab)
                        TabBarButton(icon: "list.bullet.rectangle", title: "Budget", tab: .budget, selectedTab: $selectedTab)
                        TabBarButton(icon: "gearshape", title: "Settings", tab: .settings, selectedTab: $selectedTab)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30) // Safe Area
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                    .padding(.horizontal)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let tab: MainTabView.Tab
    @Binding var selectedTab: MainTabView.Tab
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? icon + ".fill" : icon)
                    .font(.system(size: 22))
                
                Text(title)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? Theme.Colors.mint : Theme.Colors.secondaryText)
            .scaleEffect(isSelected ? 1.1 : 1.0)
        }
    }
}
