import SwiftUI

@main
struct BreathRightApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var dataManager: DataManager
    @State private var showSplash = true

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
                    NavigationView {
                        HomeView()
                    }
                    .accentColor(.white)
                    .navigationViewStyle(.stack)
                }
            }
            .animation(nil, value: showSplash)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(dataManager)
        }
    }
}
