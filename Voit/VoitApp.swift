//
//  VoitApp.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftData
import SwiftUI
import SwiftWhisper

@main
struct VoitApp: App {
    @ObservedObject var router = Router()
    @ObservedObject var transcriptionEngine = TranscriptionEngine()

    @AppStorage(AppStorageKey.selectedModel.rawValue) var model: WhisperModel = .tiny
    @AppStorage(AppStorageKey.selectedLanguage.rawValue) var lang: WhisperLanguage = .auto

    @State var showFatalCrashScreen = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recording.self,
            Transcript.self,
            Folder.self
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
            if showFatalCrashScreen {
                // TODO: fatal crash screen here
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
                .task { loadCtx() }
                .onChange(of: model) { loadCtx() }
                .onChange(of: lang) { loadCtx() }
                .environmentObject(router)
            }
        }
        .environmentObject(transcriptionEngine)
        .modelContainer(sharedModelContainer)
    }

    func loadCtx() {
        DispatchQueue.main.async {
            do {
                try transcriptionEngine.initContext()
            } catch {
                // Instead of horribly crashing, try to give the user a chance to reset their model-related settings
                showFatalCrashScreen = true
            }
        }
    }
}
