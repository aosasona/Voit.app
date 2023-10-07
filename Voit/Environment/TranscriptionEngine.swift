//
//  ProcessingQueue.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import Foundation
import SwiftUI
import SwiftWhisper

// TODO: load unprocessed recordings on startup
final class TranscriptionEngine: ObservableObject {
    @Published var hasInitializedContext = false
    @Published var importingFiles = false
    private var queue: ProcessingQueue
    private var ctx: Whisper? = nil
    private let modelController = ModelService()
    
    
    init() {
        self.queue = ProcessingQueue()
    }
    
    public var enqueuedItems: Int { return self.queue.count() }
    public var queueIsEmpty: Bool { return self.queue.count() <= 0 }
    
    func isImportingFiles() { importingFiles = true }
    func hasImportedFiles() { importingFiles = false }
    
    func initContext() throws {
        DispatchQueue.main.sync { hasInitializedContext = false }
        let params = WhisperParams(strategy: .greedy)
        params.language = .auto
        guard let modelUrl = ModelService.getModelURL(modelController.model) else { return }
        self.ctx = Whisper(fromFileURL: modelUrl, withParams: params)
        DispatchQueue.main.sync { hasInitializedContext = true }
    }
    
    func loadUnprocessedRecordings() throws {}
    
    func enqueue(_ recording: Recording) {
        self.queue.enqueue(recording)
    }
}
