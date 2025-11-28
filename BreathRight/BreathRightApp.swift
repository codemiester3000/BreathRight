import SwiftUI

@main
struct BreathRightApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
