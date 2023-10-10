//
//  ProcessingQueueListView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 07/10/2023.
//

import SwiftUI

struct ProcessingQueueListView: View {
    @EnvironmentObject var engine: TranscriptionEngine
    
    var body: some View {
        VStack {
            List {
                Text("WTF")
            }
        }
    }
}

#Preview {
    ProcessingQueueListView()
        .environmentObject(TranscriptionEngine.shared)
}
