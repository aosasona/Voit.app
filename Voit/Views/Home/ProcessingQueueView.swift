//
//  ProcessingQueueView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

struct ProcessingQueueView: View {
    @EnvironmentObject var processingQueue: ProcessingQueue
    @State private var showQueue = false

    var body: some View {
        GeometryReader { _ in
            ZStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(processingQueue.isEmpty() ? "Tap '+' to add a new recording " : "Processing \(processingQueue.count()) recording\(processingQueue.count() > 1 ? "s" : "")")
                            .font(.subheadline.weight(.medium))

                        if !processingQueue.isEmpty() {
                            Text("Tap to expand")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    AddRecordingView()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, processingQueue.isEmpty() ? 13 : 16)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
            .sheet(isPresented: $showQueue) {
                Text("Sheet")
                    .presentationDetents([.fraction(0.3), .large])
                    .presentationDragIndicator(.automatic)
            }
        }
        .onTapGesture {
            showQueue = true
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding()
    }
}

#Preview {
    ProcessingQueueView()
}
