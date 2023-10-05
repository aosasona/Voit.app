//
//  ProcessingQueue.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import Foundation
import SwiftUI
import SwiftWhisper

// TODO: load unprocessed audio files on startup
final class TranscriptionEngine: ObservableObject {
    @Published var hasInitializedContext = false
    
    private var queue: ProcessingQueue
    private var ctx: Whisper? = nil
    
    init() {
        self.queue = ProcessingQueue()
    }
    
    func initContext() throws {}
    
    func loadUnprocessedRecordings() throws {}
}
