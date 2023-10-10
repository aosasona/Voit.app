//
//  ProcessingQueueView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

struct ProcessingQueueView: View {
    @EnvironmentObject var engine: TranscriptionEngine
    @State private var showQueue = false
    
    private let animationValue = Animation.bouncy(duration: 0.4)
    
    var processing: Int { engine.queue.filter { $0.status == .processing }.count }
    var statusText: String {
        return if !engine.hasInitializedContext {
            "Loading model, please wait..."
        } else if engine.importingFiles {
            "Importing files..."
        } else if engine.queue.count <= 0 {
            "Tap '+' to add a new recording "
        } else {
            "\(engine.queue.count) queued, \(processing) processing"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(statusText)
                    .font(.subheadline.weight(.medium))
                    .animation(animationValue)
                
                if engine.queue.count > 0 {
                    Text("Tap to expand")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .animation(animationValue)
                }
            }
            
            Spacer()
            
            if !engine.hasInitializedContext || engine.importingFiles {
                ProgressView()
                    .animation(animationValue, value: engine.hasInitializedContext)
                    .padding(.all, 6)
            } else {
                AddRecordingView()
                    .animation(animationValue, value: engine.hasInitializedContext)
            }
        }
        .animation(animationValue, value: engine.hasInitializedContext)
        .padding(.horizontal, 16)
        .padding(.vertical, engine.queue.count <= 0 && engine.hasInitializedContext ? 13 : 16)
        .sheet(isPresented: $showQueue) {
            ProcessingQueueListView()
        }
    }
}

#Preview {
    ProcessingQueueView()
        .environmentObject(TranscriptionEngine())
}
