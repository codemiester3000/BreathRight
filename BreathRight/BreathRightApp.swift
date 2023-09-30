//
//  BreathRightApp.swift
//  BreathRight
//
//  Created by Owen Khoury on 9/30/23.
//

import SwiftUI

@main
struct BreathRightApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
