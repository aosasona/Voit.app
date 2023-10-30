//
//  RecordingManager.swift
//  Voit
//
//  Created by Ayodeji Osasona on 21/10/2023.
//

import AudioKit
import Combine
import Foundation

enum RecordingManagerError: String, Error {
    case noUrlPresent = "Recording has no URL present, failed to load"
    case audioPlayerFailedToLoad = "Could not load audio file, something went wrong"
}

final class RecordingManager: ObservableObject {
    static let shared = RecordingManager()
    
    private let audioPlayer = AudioPlayer()
    
    @Published public var recording: Recording? = nil
    @Published public var isPlaying: Bool = false
    
    public func loadRecording(recording: Recording) throws {
        self.recording = recording
        if let url = self.recording?.path {
            do {
                try audioPlayer.load(url: url, buffered: (self.recording?.duration ?? 0) <= 60.0)
            } catch {
                print(error.localizedDescription)
                throw RecordingManagerError.audioPlayerFailedToLoad
            }
        } else {
            throw RecordingManagerError.noUrlPresent
        }
    }
    
    public func resume() {}
    
    public func pause() {}
    
    public func showRecordingView(recording: Recording) {
        self.recording = recording
    }
}
