//
//  SettingsView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink(destination: Text("Appearance")) {
                    Label("Appearance", systemImage: "paintpalette")
                }
                NavigationLink(destination: Text("Appearance")) {
                    Label("Appearance", systemImage: "paintpalette")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
    SettingsView()
}
