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
    
    private var queue: ProcessingQueue
    private var ctx: Whisper? = nil
    
    init() {
        self.queue = ProcessingQueue()
    }
    
    public var enqueuedItems: Int { return self.queue.count() }
    public var queueIsEmpty: Bool { return self.queue.count() <= 0 }
    
    func initContext() throws {}
    
    func loadUnprocessedRecordings() throws {}
}
