//
//  SettingsView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

// TODO: add licenses
// TODO: load custom models from models directory

struct SettingsView: View {
    @AppStorage(AppStorageKey.selectedModel.rawValue) var selectedModel: WhisperModel = .tiny

    var body: some View {
        List {
            Section {
                Picker("Select model", selection: $selectedModel) {
                    Text("Tiny (default)").tag(WhisperModel.tiny)
                    Text("Standard").tag(WhisperModel.base)
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
