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

struct SettingsView: View {
    @AppStorage(AppStorageKey.selectedModel.rawValue) var selectedModel: WhisperModel = .tiny
    @AppStorage(AppStorageKey.selectedLanguage.rawValue) var selectedLanguage: WhisperLanguage = .auto

    var body: some View {
        List {
            Section(footer: Text("Changes here may cause the app to be unresponsive for very few seconds, this is normal as the app needs to reload the model to apply the changes (this may be improved in the future).")) {
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
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
    SettingsView()
}
