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

    @Query(sort: \Recording.createdAt, order: .reverse, animation: .easeOut) var allRecordings: [Recording]
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
                NavigationLink {
                    RecordingView(recording: recording)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                } label: {
                    RecordingListItem(recording: recording)
                }
            }
        }
        .searchable(text: $searchQuery)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink(destination: FoldersListView()) { Label("Go to folders", systemImage: "folder") }

                Menu {
                    // TODO: add picker for sorting here
                    NavigationLink(destination: SettingsView()) { Label("Settings", systemImage: "gear") }
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
}
