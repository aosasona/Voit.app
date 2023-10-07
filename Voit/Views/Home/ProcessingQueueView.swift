//
//  ProcessingQueueView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

struct ProcessingQueueView: View {
    @Namespace private var animation
    @EnvironmentObject var transcriptionEngine: TranscriptionEngine
    @State private var showQueue = false
    @State private var offset = CGSize.zero

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
        ZStack(alignment: .bottom) {
            if showQueue {
                ProcessingQueueListView(showQueue: $showQueue)
            } else {
                HStack {
                    VStack(alignment: .leading) {
                        Text(statusText)
                            .font(.subheadline.weight(.medium))
                            .animation(.spring)

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
                            .animation(.spring, value: transcriptionEngine.hasInitializedContext)
                    } else {
                        ProgressView()
                            .animation(.spring, value: transcriptionEngine.hasInitializedContext)
                            .padding([.all], 6)
                    }
                }
                .animation(.spring, value: transcriptionEngine.hasInitializedContext)
                .padding(.horizontal, 16)
                .padding(.vertical, showQueue ? 6 : transcriptionEngine.queueIsEmpty && transcriptionEngine.hasInitializedContext ? 13 : 16)
                .matchedGeometryEffect(id: "FullQueue", in: animation)
            }
        }
        .zIndex(99)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        .onTapGesture {
            withAnimation(.bouncy(duration: 0.5)) {
                if !transcriptionEngine.queueIsEmpty { showQueue = true }
            }
        }
        .fixedSize(horizontal: false, vertical: !showQueue)
        .padding(.horizontal)
    }
}

#Preview {
    ProcessingQueueView()
        .environmentObject(TranscriptionEngine())
}
