import SwiftUI

// MARK: - Tab Bar Visibility

class TabBarState: ObservableObject {
    @Published var isVisible: Bool = true
}

@main
struct BreathRightApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var dataManager: DataManager
    @StateObject private var tabBarState = TabBarState()
    @State private var showSplash = true
    @State private var selectedTab: AppTab = .breathe

    init() {
        let controller = PersistenceController.shared
        _dataManager = StateObject(wrappedValue: DataManager(container: controller.container))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreen(onFinished: {
                        showSplash = false
                    })
                } else {
                    ZStack(alignment: .bottom) {
                        // Tab content
                        Group {
                            switch selectedTab {
                            case .breathe:
                                NavigationView {
                                    HomeView()
                                }
                                .navigationViewStyle(.stack)
                            case .journey:
                                NavigationView {
                                    StatsView(isTab: true)
                                }
                                .navigationViewStyle(.stack)
                            }
                        }
                        .accentColor(.white)

                        // Custom tab bar — hidden when in detail views
                        if tabBarState.isVisible {
                            CustomTabBar(selectedTab: $selectedTab)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: tabBarState.isVisible)
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .animation(nil, value: showSplash)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(dataManager)
            .environmentObject(tabBarState)
        }
    }
}

// MARK: - Tab Enum

enum AppTab {
    case breathe
    case journey
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 4) {
            tabItem(tab: .breathe, icon: "wind", label: "Breathe")
            tabItem(tab: .journey, icon: "chart.line.uptrend.xyaxis", label: "Journey")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.homeWarmBlueDark.opacity(0.85))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.35), radius: 16, y: 8)
        )
        .padding(.bottom, 28)
    }

    private func tabItem(tab: AppTab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab

        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tab
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                Text(label)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
            }
            .foregroundColor(isSelected ? Color.homeGoldenAccent : .white.opacity(0.4))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                isSelected
                    ? Capsule().fill(Color.homeGoldenAccent.opacity(0.12))
                    : Capsule().fill(Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
