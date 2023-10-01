//
//  ContentView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

struct Root: View {
    @EnvironmentObject var router: Router

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationTitle("All recordings")
                .navigationDestination(for: Router.Screen.self) { screen in
                    switch screen {
                    case .Home:
                        HomeView()
                    case .Settings:
                        SettingsView()
                    }
                }
        }
    }
}

#Preview {
    Root()
}
