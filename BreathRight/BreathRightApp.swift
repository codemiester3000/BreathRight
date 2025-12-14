import SwiftUI

@main
struct BreathRightApp: App {
    let persistenceController = PersistenceController.shared
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreen(onFinished: {
                        showSplash = false
                    })
                } else {
                    NavigationView {
                        HomeView()
                    }
                    .accentColor(.white)
                    .navigationViewStyle(.stack)
                }
            }
            .animation(nil, value: showSplash)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
