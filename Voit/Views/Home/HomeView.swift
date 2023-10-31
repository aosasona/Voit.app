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

                ProcessingQueueView()
                    .safeAreaPadding()
            }
        }
        .onChange(of: engine.hasInitializedContext) {
            DispatchQueue(label: "load.unprocessed.recordings").sync {
                if engine.hasInitializedContext { fetchUnprocessedRecordings() }
            }
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
            DispatchQueue.main.async {
                engine.enqueueMultiple(recordings)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(TranscriptionEngine())
}
