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
    @Published var hasInitializedContext = false
    @Published var importingFiles = false
    
    private var queue: ProcessingQueue
    private var ctx: Whisper? = nil
    private let modelController = ModelService()
    
    public var enqueuedItems: Int { return self.queue.count() }
    public var queueIsEmpty: Bool { return self.queue.count() <= 0 }
    
    init() {
        self.queue = ProcessingQueue()
    }
    
    func isImportingFiles() { self.importingFiles = true }
    
    func hasImportedFiles() { self.importingFiles = false }
    
    func enqueue(_ recording: Recording) { self.queue.enqueue(recording) }
    func pop(_ recording: Recording) { self.queue.pop(recording) }
    
    public func initContext() throws {
        DispatchQueue.main.sync { self.hasInitializedContext = false }
        let params = WhisperParams(strategy: .greedy)
        params.language = .auto
        guard let modelUrl = ModelService.getModelURL(modelController.model) else { return }
        self.ctx = Whisper(fromFileURL: modelUrl, withParams: params)
        DispatchQueue.main.sync { self.hasInitializedContext = true }
    }
}
