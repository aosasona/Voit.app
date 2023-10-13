//
//  Home.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) var context
    @EnvironmentObject var engine: TranscriptionEngine

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                RecordingsListView()
                    .navigationTitle("All recordings")
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

                ProcessingQueueView()
                    .safeAreaPadding()
            }
        }
        .onChange(of: engine.hasInitializedContext) {
            if engine.hasInitializedContext { fetchUnprocessedRecordings() }
        }
    }

    func fetchUnprocessedRecordings() {
        let processed = Recording.Status.processed.rawValue
        let descriptor = FetchDescriptor<Recording>(
            predicate: #Predicate { $0._status != processed },
            sortBy: [SortDescriptor(\.createdAt, order: .forward), SortDescriptor(\._status, order: .forward)]
        )

        do {
            let recordings: [Recording] = try context.fetch(descriptor)
            engine.enqueueMultiple(recordings)
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(TranscriptionEngine())
}
