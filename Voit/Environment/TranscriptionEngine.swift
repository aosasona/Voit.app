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

enum TranscriptionError: Error {
    case noAudioFrames
    case noSegments
}

final class TranscriptionEngine: ObservableObject {
    static let shared = TranscriptionEngine()
    
    @Published var hasInitializedContext = false
    @Published var importingFiles = false
    @Published var queue = [Recording]()
    
    private var ctx: Whisper? = nil
    private let modelController = ModelService()
    private var isLocked = false
    private var workItem: DispatchWorkItem? = nil
    
    // Queue methods
    public func enqueue(_ recording: Recording) {
        // make sure it hasn't failed one too many times before adding it to the queue
        guard recording.failedAttempts < 5 else { return }
        self.queue.append(recording)
    }

    public func enqueueMultiple(_ recordings: [Recording]) { recordings.forEach { self.enqueue($0) } }
    private func next() -> Recording? { return self.queue.first }
    public func dequeue(_ recording: Recording) { self.queue.removeAll(where: { $0.id == recording.id }) }
    public func dequeue() {
        guard self.queue.count > 0 else { return }
        self.queue.remove(at: 0)
    }
    
    // Engine methods
    public func isImportingFiles() { self.importingFiles = true }
    public func hasImportedFiles() { self.importingFiles = false }
    
    public func initWhisperCtx() throws {
        DispatchQueue.main.async { self.hasInitializedContext = false }
        let params = WhisperParams(strategy: .greedy)
        params.language = self.modelController.language
        guard let modelUrl = ModelService.getModelURL(modelController.model) else { return }
        self.ctx = Whisper(fromFileURL: modelUrl, withParams: params)
        DispatchQueue.main.async { self.hasInitializedContext = true }
    }
    
    private func lock() { self.isLocked = true }
    private func unlock() { self.isLocked = false }
    
    public func cancel(_ recording: Recording) throws {
        if let inProgress = self.ctx?.inProgress {
            if inProgress { try? self.ctx?.cancel {} }
        }
        
        self.workItem?.cancel()
        DispatchQueue.main.async {
            if let recording = self.next() { recording.update(keyPath: \.status, to: .pending) }
            self.dequeue(recording)
        }
        self.workItem = nil
        self.startProcessing()
    }
    
    private func transcribe(frames audioFrames: [Float], recording: Recording) throws -> [Segment] {
        var err: Error? = nil
        var segments = [Segment]()
            
        self.ctx?.transcribe(audioFrames: audioFrames) { result in
            switch result {
            case .failure(let e): err = e
            case .success(let segs): segments = segs
            }
        }
            
        if let e = err { throw e }
        return segments
    }
    
    private func toAudioFrames(path: URL) throws -> [Float] {
        var err: Error? = nil
        var frames = [Float]()
        
        AudioService.convertToPCMArray(input: path) { result in
            switch result {
            case .failure(let e): err = e
            case .success(let audioFrames): frames = audioFrames
            }
        }
        
        if let e = err { throw e }
        return frames
    }
    
    private func process(_ recording: Recording, onComplete: @escaping () -> Void) throws {
        // Ensure only one item will be processed at once
        if self.isLocked { return }
        
        // Acquire lock
        self.lock()
        
        // Prevent recordings that have failed one too many times from being processed
        if recording.failedAttempts >= 5 {
            DispatchQueue.main.async { self.dequeue(recording) }
            print("Failed too many times, will not retry (\(recording.title)")
            return
        }
        
        DispatchQueue.main.async { recording.update(keyPath: \.status, to: .processing) } // notify UI of status
        
        guard let path = recording.path else {
            print("Unable to get path for \(recording.title)")
            return
        }
        
        guard let frames = try? self.toAudioFrames(path: path) else { throw TranscriptionError.noAudioFrames }
        guard let rawSegments = try? self.transcribe(frames: frames, recording: recording) else { throw TranscriptionError.noSegments }
        
        let segments = rawSegments.map { TranscriptSegment(text: $0.text, startTime: $0.startTime, endTime: $0.endTime) }
        DispatchQueue.main.async { recording.update(keyPath: \.transcript, to: Transcript(segments: segments)) }
        
        onComplete()
    }
     
    /// Start processing items in the queue recursively
    public func startProcessing() {
        self.workItem = DispatchWorkItem {
            guard !self.isLocked else { return }
            guard let recording = self.next() else { return }
            
            do {
                try self.process(recording) {
                    recording.update(keyPath: \.status, to: .processed)
                    
                    // Remove from queue, release lock and recursely process next item
                    // TODO: send notification on completion if enabled
                    DispatchQueue.main.async { self.dequeue() }
                    self.unlock()
                    self.startProcessing()
                }
            } catch {
                recording.update(keyPath: \.status, to: .failed)
                recording.update(keyPath: \.failedAttempts, to: recording.failedAttempts + 1)
                print("Error processing `\(recording.title)` (\(recording.id.uuidString): \(error.localizedDescription)")
            }
        }
        
        if let wk = self.workItem {
            DispatchQueue.global(qos: .background).async(execute: wk)
        }
    }
}
