//
//  SettingsView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

// TODO: add licenses

struct SettingsView: View {
    @AppStorage(AppStorageKey.selectedModel.rawValue) var selectedModel: WhisperModels = .tiny

    var body: some View {
        List {
            Section {
                Picker("Select model", selection: $selectedModel) {
                    Text("Tiny (default)").tag(WhisperModels.tiny)
                    Text("Standard").tag(WhisperModels.base)
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
