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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationSplitView {
                RecordingsListView()
                    .navigationTitle("All recordings")
            } detail: {}

            ProcessingQueueView()
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    func loadUnprocessedRecordings() {
//        let descriptor = FetchDescriptor(
//            predicate: #Predicate<Recording> 
//        )
    }
}

#Preview {
    HomeView()
}
