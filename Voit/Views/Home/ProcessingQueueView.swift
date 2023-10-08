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

    private let animationValue = Animation.bouncy(duration: 0.4)

    var statusText: String {
        return if !transcriptionEngine.hasInitializedContext {
            "Loading model, please wait..."
        } else if transcriptionEngine.importingFiles {
            "Importing files..."
        } else if transcriptionEngine.queue.count <= 0 {
            "Tap '+' to add a new recording "
        } else {
//            "\(transcriptionEngine.queue.count) recording\(transcriptionEngine.queue.count > 1 ? "s" : "") queued"
            "\(transcriptionEngine.queued) queued, \(transcriptionEngine.processing) processing"
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
                            .animation(animationValue)

                        if transcriptionEngine.queue.count > 0 {
                            Text("Tap to expand")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .animation(animationValue)
                        }
                    }

                    Spacer()

                    if !transcriptionEngine.hasInitializedContext || transcriptionEngine.importingFiles {
                        ProgressView()
                            .animation(animationValue, value: transcriptionEngine.hasInitializedContext)
                            .padding(.all, 6)
                    } else {
                        AddRecordingView()
                            .animation(animationValue, value: transcriptionEngine.hasInitializedContext)
                    }
                }
                .animation(animationValue, value: transcriptionEngine.hasInitializedContext)
                .padding(.horizontal, 16)
                .padding(.vertical, showQueue ? 6 : transcriptionEngine.queue.count <= 0 && transcriptionEngine.hasInitializedContext ? 13 : 16)
                .matchedGeometryEffect(id: "FullQueue", in: animation)
            }
        }
        .zIndex(99)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
        .onTapGesture {
            withAnimation(.bouncy(duration: 0.4)) {
                if transcriptionEngine.queue.count > 0 { showQueue = true }
            }
        }
        .fixedSize(horizontal: false, vertical: !showQueue)
        .padding(.horizontal, showQueue ? 0 : 20.0)
        .padding(.bottom, showQueue ? 0 : 20.0)
        .safeAreaPadding(showQueue ? .top : .bottom)
    }
}

#Preview {
    ProcessingQueueView()
        .environmentObject(TranscriptionEngine())
}
