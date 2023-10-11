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
    @ObservedObject var transcriptionEngine = TranscriptionEngine.shared

    @AppStorage(AppStorageKey.selectedModel.rawValue) var model: WhisperModel = .tiny
    @AppStorage(AppStorageKey.selectedLanguage.rawValue) var lang: WhisperLanguage = .auto

    @State var showFatalCrashScreen = false

    private var ctxQueue = DispatchQueue(label: "queue.ctx")

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
            if self.showFatalCrashScreen {
                VStack {
                    Text("Something went horribly wrong, please restart the app!")
                }
                .foregroundStyle(.white)
                .background(.red)
                .edgesIgnoringSafeArea(.all)
            } else {
                HomeView()
                    .tint(.accentColor)
                    .task { self.loadCtx() }
                    .onChange(of: self.model) { self.loadCtx() }
                    .onChange(of: self.lang) { self.loadCtx() }
                    .onChange(of: self.transcriptionEngine.queue.count) {
                        if self.transcriptionEngine.isLocked { return }
                        self.transcriptionEngine.startProcessing()
                    }
            }
        }
        .environmentObject(self.transcriptionEngine)
        .modelContainer(self.sharedModelContainer)
    }

    func loadCtx() {
        self.ctxQueue.async {
            do {
                try self.transcriptionEngine.initWhisperCtx()
            } catch {
                print("Failed to init whisper context: \(error.localizedDescription)")
                DispatchQueue.main.sync {
                    // Instead of horribly crashing, try to give the user a chance to reset their model-related settings
                    self.showFatalCrashScreen = true
                }
            }
        }
    }
}
