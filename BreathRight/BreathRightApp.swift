import SwiftUI

@main
struct BreathRightApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            .accentColor(.white) // This sets the navigation bar item color to white
        }
    }
}
