//
//  RecordingsListView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftData
import SwiftUI

struct RecordingsListView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var router: Router
    @Query(sort: \Recording.createdAt, order: .reverse, animation: .easeOut) var allRecordings: [Recording]

    @State private var selectedRecordings = Set<Recording>()
    @State private var searchQuery: String = ""
    var recordings: [Recording] {
        guard searchQuery.isEmpty == false else { return allRecordings }
        // TODO: make transcripts searchable
        return allRecordings.filter { recording in
            recording.title.lowercased().contains(searchQuery.lowercased())
        }
    }

    var body: some View {
        List {
            ForEach(recordings, id: \.self) { recording in
                RecordingListItem(recording: recording)
            }
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
            if !searchQuery.isEmpty, recordings.isEmpty {
                ContentUnavailableView.search
            }
        }
    }
}

#Preview {
    RecordingsListView()
        .environmentObject(Router())
}
