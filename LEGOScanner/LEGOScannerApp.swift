//
//  LEGOScannerApp.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/12/26.
//

import SwiftUI
import CoreData

@main
struct LEGOScannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
