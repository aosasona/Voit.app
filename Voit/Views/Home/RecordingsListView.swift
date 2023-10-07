//
//  RecordingsListView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftData
import SwiftUI

struct RecordingsListView: View {
    @EnvironmentObject private var router: Router
    @Query var recordings: [Recording]

    @State private var searchQuery: String = ""
    var searchResults: [Recording] {
        guard searchQuery.isEmpty == false else { return recordings }
        return recordings.filter { $0.title.contains(searchQuery) }
    }

    var body: some View {
        List(recordings) { _ in
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .searchable(text: $searchQuery)
        .toolbar {
            ToolbarItem {
                Button(action: { router.navigate(to: .folders) }) {
                    Label("Go to folders", systemImage: "folder")
                }
            }

            ToolbarItem {
                Menu {
                    EditButton()
                    // TODO: add picker for sorting here
                    Button(action: { router.navigate(to: .settings(.root)) }, label: {
                        Label("Settings", systemImage: "gear")
                    })
                } label: {
                    Label("Show options", systemImage: "ellipsis.circle")
                }
            }
        }
        .overlay {
            if !searchQuery.isEmpty, searchResults.isEmpty {
                ContentUnavailableView.search
            }
        }
    }
}

#Preview {
    RecordingsListView()
        .environmentObject(Router())
}
