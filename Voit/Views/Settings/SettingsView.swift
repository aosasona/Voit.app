//
//  SettingsView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI
import SwiftWhisper

// TODO: add licenses
// TODO: load custom models from models directory
enum ImportBehaviour: String, Identifiable, CaseIterable {
    case copy = "Copy"
    case move = "Move"

    var id: Self { self }
}

struct SettingsView: View {
    @AppStorage(AppStorageKey.selectedModel.rawValue) var selectedModel: WhisperModel = .tiny
    @AppStorage(AppStorageKey.selectedLanguage.rawValue) var selectedLanguage: WhisperLanguage = .auto
    @AppStorage(AppStorageKey.allowNotifications.rawValue) var allowNotifications: Bool = false
    @AppStorage(AppStorageKey.importBehaviour.rawValue) var importBehaviour: ImportBehaviour = .copy

    @State var showErrorAlert = false
    @State var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Enable notifications", isOn: $allowNotifications)
                }

                Section {
                    Picker("Model", selection: $selectedModel) {
                        Text("Tiny (default)").tag(WhisperModel.tiny)
                        Text("Standard").tag(WhisperModel.base)
                    }

                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(WhisperLanguage.allCases) { lang in
                            Text(lang.displayName.capitalized).tag(lang)
                        }
                    }
                }
                .pickerStyle(.menu)

                Section(footer: Text("Copy or move imported files from the source directory")) {
                    Picker("Import behaviour", selection: $importBehaviour) {
                        ForEach(ImportBehaviour.allCases) { behaviour in
                            Text(behaviour.rawValue).tag(behaviour)
                        }
                    }
                }
                .pickerStyle(.menu)
            }
            .navigationTitle("Settings")
            .onChange(of: allowNotifications) { _, newValue in
                if newValue { requestNotificationsPerm() }
            }
            .alert(errorMessage ?? "Something went wrong", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel, action: {})
            }
        }
    }

    func triggerAlert(_ message: String) {
        showErrorAlert = true
        errorMessage = message
    }

    func requestNotificationsPerm() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Failed to get notifications permission: \(error.localizedDescription)")
                triggerAlert("Failed to get notifications permission")
            }

            if !success {
                print("Somehow failed to get notifications perm?")
                triggerAlert("Failed to get notifications permission")
            }
        }
    }
}

#Preview {
    SettingsView()
}
