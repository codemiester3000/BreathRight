import SwiftUI

@main
struct BreathRightApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                // Home Tab with BoxBreathingView
                NavigationView {
                    MainView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }

                // Settings Tab (you'll need to create a SettingsView)
                NavigationView {
                    SettingsView() // Replace with your actual settings view
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
    }
}
