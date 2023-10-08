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

final class TranscriptionEngine: ObservableObject {
    static let shared = TranscriptionEngine()
    
    @Published var hasInitializedContext = false
    @Published var importingFiles = false
    @Published var queue = [Recording]()
    
    private var ctx: Whisper? = nil
    private let modelController = ModelService()
    private var dispatchQueue = DispatchQueue(label: "voit.transcription.queue", qos: .background)
    
    public var queued: Int { return self.queue.filter { $0.status == .pending }.count }
    public var processing: Int { return self.queue.filter { $0.status == .processing }.count }
    
    // Queue methods
    public func enqueue(_ recording: Recording) { self.queue.append(recording) }
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
        params.language = .auto
        guard let modelUrl = ModelService.getModelURL(modelController.model) else { return }
        self.ctx = Whisper(fromFileURL: modelUrl, withParams: params)
        DispatchQueue.main.async { self.hasInitializedContext = true }
    }
    
    public func cancel(_ recording: Recording) throws {}
    
    public func process(_ currentRecording: Recording) throws {
        if let locked = self.ctx?.inProgress {
            if locked { return }
        }
//
        // TODO: better error handling
        var err: Error? = nil
        
        guard currentRecording.failedAttempts <= 5 else {
            DispatchQueue.main.async { self.dequeue() }
            print("Failed too many times, will not retry (\(currentRecording.title)")
            return
        }
        
        currentRecording.status = .processing
        
        defer {
            DispatchQueue.main.async {
                guard let e = err else {
                    self.dequeue()
                    return
                }
                
                print("Processing error: \(e.localizedDescription)")
                currentRecording.failedAttempts += 1
                currentRecording.status = .failed
                self.dequeue()
                self.enqueue(currentRecording)
            }
        }
        
        guard let path = currentRecording.path else { return }
        
        AudioService.convertToPCMArray(input: path) { result in
            switch result {
            case .failure(let e):
                err = e
                return
            case .success(let audioFrames):
                do {
                    try self.transcribe(audioFrames, recording: currentRecording)
                } catch {
                    err = error
                    return
                }
            }
        }
    }
    
    private func transcribe(_ audioFrames: [Float], recording: Recording) throws {
        var err: Error? = nil
            
        self.ctx?.transcribe(audioFrames: audioFrames) { result in
            switch result {
            case .failure(let e):
                err = e
            case .success(let segments):
                let processedSegments = segments.map { TranscriptSegment(text: $0.text, startTime: $0.startTime, endTime: $0.endTime) }
                recording.transcript = Transcript(segments: processedSegments)
                recording.status = .processed
            }
        }
            
        guard let globalErr = err else { return }
        throw globalErr
    }
     
    /// Start processing items in the queue
    public func startProcessing() {
        // TODO: try processing on change instead of this horrible loop and well, use the custom dispatchQueue as the queue it is (sync of course)
        self.dispatchQueue.async {
            while true {
                if !self.hasInitializedContext { continue }
                if let recording = self.next() {
                    do {
                        try self.process(recording)
                    } catch {
                        print("Failed to process recording: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
