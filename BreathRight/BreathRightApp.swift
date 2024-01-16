import SwiftUI

@main
struct BreathRightApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                MainView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            .accentColor(.white) // This sets the navigation bar item color to white
        }
    }
}
