//
//  ProcessingQueue.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import Foundation
import SwiftUI
import SwiftWhisper

enum ContextInitialisationError {
    case modelNotFound
}

// TODO: load unprocessed recordings on startup
final class TranscriptionEngine: ObservableObject {
    @Published var hasInitializedContext = false
    private var queue: ProcessingQueue
    private var ctx: Whisper? = nil
    private let modelController = ModelController()
    
    
    init() {
        self.queue = ProcessingQueue()
    }
    
    public var enqueuedItems: Int { return self.queue.count() }
    public var queueIsEmpty: Bool { return self.queue.count() <= 0 }
    
    func initContext() throws {
        hasInitializedContext = false
        let params = WhisperParams(strategy: .greedy)
        params.language = .auto
        guard let modelUrl = ModelController.getModelURL(modelController.model) else { return }
        self.ctx = Whisper(fromFileURL: modelUrl, withParams: params)
        hasInitializedContext = true
    }
    
    func loadUnprocessedRecordings() throws {}
}
