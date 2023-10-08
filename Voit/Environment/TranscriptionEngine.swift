//
//  ProcessingQueue.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import Foundation
import SwiftData
import SwiftUI
import SwiftWhisper

// TODO: load unprocessed recordings on startup
// TODO: fix floating queue status being out of sync with elements
final class TranscriptionEngine: ObservableObject {
    static let shared = TranscriptionEngine()
    
    @Published var hasInitializedContext = false
    @Published var importingFiles = false
    @Published var queue = [Recording]()
    
    private var ctx: Whisper? = nil
    private let modelController = ModelService()
    
    public func initWhisperCtx() throws {
        DispatchQueue.main.sync { self.hasInitializedContext = false }
        let params = WhisperParams(strategy: .greedy)
        params.language = .auto
        guard let modelUrl = ModelService.getModelURL(modelController.model) else { return }
        self.ctx = Whisper(fromFileURL: modelUrl, withParams: params)
        DispatchQueue.main.sync { self.hasInitializedContext = true }
    }
    
    public func isImportingFiles() { self.importingFiles = true }
    public func hasImportedFiles() { self.importingFiles = false }
    
    // Queue methods
    public func enqueue(_ recording: Recording) { self.queue.append(recording) }
    public func enqueueMultiple(_ recordings: [Recording]) { recordings.forEach { self.enqueue($0) } }
    private func next() -> Recording? { return self.queue.first }
    public func dequeue(_ recording: Recording) { self.queue.removeAll(where: { $0.id == recording.id }) }
    public func dequeue() {
        guard self.queue.count > 0 else { return }
        self.queue.remove(at: 0)
    }
}
