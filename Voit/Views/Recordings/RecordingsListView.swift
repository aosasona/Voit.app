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
        return allRecordings.filter { recording in
            let query = searchQuery.lowercased()
            if let transcript = recording.transcript {
                return recording.title.lowercased().contains(query) || transcript.containsText(text: query)
            } else {
                return recording.title.lowercased().contains(query)
            }
        }
    }

    var body: some View {
        List {
            ForEach(recordings, id: \.self) { recording in
                RecordingListItem(recording: recording)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchQuery)
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
