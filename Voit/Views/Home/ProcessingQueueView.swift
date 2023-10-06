//
//  ProcessingQueueView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

// TODO: show context loading state and prevent importing files during that period ("Reloading model, please wait...")

struct ProcessingQueueView: View {
    @EnvironmentObject var transcriptionEngine: TranscriptionEngine
    @State private var showQueue = false

    var statusText: String {
        return if !transcriptionEngine.hasInitializedContext {
            "Loading model, please wait..."
        } else if transcriptionEngine.queueIsEmpty {
            "Tap '+' to add a new recording "
        } else {
            "Processing \(transcriptionEngine.enqueuedItems) recording\(transcriptionEngine.enqueuedItems > 1 ? "s" : "")"
        }
    }

    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(statusText)
                        .font(.subheadline.weight(.medium))
                        .animation(.easeOut)

                    if !transcriptionEngine.queueIsEmpty {
                        Text("Tap to expand")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .animation(.spring)
                    }
                }

                Spacer()

                if transcriptionEngine.hasInitializedContext {
                    AddRecordingView()
                } else {
                    ProgressView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, transcriptionEngine.queueIsEmpty && transcriptionEngine.hasInitializedContext ? 13 : 16)
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
        .padding(.horizontal)
    }
}

#Preview {
    ProcessingQueueView()
}
