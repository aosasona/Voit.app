//
//  ProcessingQueueView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

struct ProcessingQueueView: View {
    @EnvironmentObject var transcriptionEngine: TranscriptionEngine
    @State private var showQueue = false

    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(transcriptionEngine.queueIsEmpty ? "Tap '+' to add a new recording " : "Processing \(transcriptionEngine.enqueuedItems) recording\(transcriptionEngine.enqueuedItems > 1 ? "s" : "")")
                        .font(.subheadline.weight(.medium))

                    if !transcriptionEngine.queueIsEmpty {
                        Text("Tap to expand")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                AddRecordingView()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, transcriptionEngine.queueIsEmpty ? 13 : 16)
        }
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        .sheet(isPresented: $showQueue) {
            Text("Sheet")
                .presentationDetents([.fraction(0.3), .large])
                .presentationDragIndicator(.automatic)
        }
        .onTapGesture {
            if !transcriptionEngine.queueIsEmpty { showQueue = true }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
    }
}

#Preview {
    ProcessingQueueView()
}
