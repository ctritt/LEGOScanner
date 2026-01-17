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
    let persistenceController = CoreDataManager.shared
    init() {
        // Configure appearance
        configureAppearance()
    }
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
    private func configureAppearance() {
        // Navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemRed
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }
}
