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
                VStack {
                    Text("Something went horribly wrong, please restart the app!")
                }
                .foregroundStyle(.white)
                .background(.red)
                .edgesIgnoringSafeArea(.all)
            } else {
                NavigationStack(path: $router.path) {
                    HomeView()
                        .navigationDestination(for: Router.Screen.self) { screen in
                            switch screen {
                            case .recording(let uuid):
                                RecordingView(uuid: uuid)
                            case .folders:
                                FoldersListView()
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
        DispatchQueue.global().async {
            do {
                try transcriptionEngine.initContext()
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.sync {
                    // Instead of horribly crashing, try to give the user a chance to reset their model-related settings
                    showFatalCrashScreen = true
                }
            }
        }
    }
}
