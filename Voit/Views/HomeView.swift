//
//  Home.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: Router
    @Query var recordings: [Recording]

    func openSettings() {
        router.navigate(to: .settings(.root))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationSplitView {
                List(recordings) { _ in
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                }
                .navigationTitle("All recordings")
                .toolbar {
                    Button(action: openSettings, label: {
                        Label("Go to settings page", systemImage: "gear")
                    })
                }
            } detail: {
                Text("Hey")
            }

            ProcessingQueueView()
                .padding([.bottom], 30)
        }
        .safeAreaPadding([.bottom])
    }
}

#Preview {
    HomeView()
}
