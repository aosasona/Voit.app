//
//  VoitApp.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftData
import SwiftUI

@main
struct VoitApp: App {
    @AppStorage(AppStorageKey.hasCompletedSetup.rawValue) var hasCompletedSetup: Bool = false
    
    @ObservedObject var router = Router()
    @ObservedObject var processingQueue = ProcessingQueue()
    
    // TODO: make sure at least one model exists before trying to load app (download model during app setup)

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recording.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if !hasCompletedSetup {
                SetupView()
            } else {
                NavigationStack(path: $router.path) {
                    HomeView()
                        .navigationDestination(for: Router.Screen.self) { screen in
                            switch screen {
                            case .settings(let page):
                                switch page {
                                case .root:
                                    SettingsView()
                                }
                            default:
                                HomeView()
                            }
                        }
                }
                .tint(.accentColor)
                .environmentObject(router)
                .environmentObject(processingQueue)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
