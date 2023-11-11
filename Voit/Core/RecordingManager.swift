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

enum SeekDirection {
    case forwards
    case backwards
}

final class RecordingManager: ObservableObject {
    static let shared = RecordingManager()
    
    let mixer: Mixer
    private let engine = AudioEngine()
    public let player = AudioPlayer()
    
    @Published public var recording: Recording? = nil
    @Published public var isPlaying: Bool = false
    @Published public var playbackSpeed: Double = 1.0
    
    init() {
        mixer = Mixer()
        mixer.addInput(player)
        engine.output = mixer
        
        do {
            try AudioKit.Settings.setSession(category: .playback, with: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP])
            try engine.start()
        } catch {
            print("AudioEngine Error: \(error.localizedDescription)")
        }
    }
    
    public func play(recording: Recording) throws {
        self.recording = recording
        let shouldBuffer = (self.recording?.duration ?? 0) <= 120.0
        if !engine.avEngine.isRunning { try? engine.start() }
        if player.isPlaying { player.stop() }
        
        if let url = self.recording?.path {
            do {
                try player.load(url: url, buffered: shouldBuffer)
            } catch {
                print(error.localizedDescription)
                throw RecordingManagerError.audioPlayerFailedToLoad
            }
            
            player.isLooping = shouldBuffer
            player.play()
            isPlaying = true
        } else {
            throw RecordingManagerError.noUrlPresent
        }
    }
    
    public func resume() {
        player.play()
        isPlaying = true
    }
    
    public func pause() {
        player.pause()
        isPlaying = false
    }
    
    public func setPlaybackSpeed(speed: Double) {
        playbackSpeed = speed
    }
    
    private func seek(duration: Double, direction: SeekDirection) {
        let seekTime: Double
        if direction == .forwards {
            seekTime = min(duration, player.duration - player.currentTime)
        } else {
            seekTime = -min(duration, player.currentTime)
        }
        player.seek(time: seekTime)
        
        if !player.isStarted {
            player.play()
            isPlaying = true
        }
    }
    
    public func goForwards(_ duration: Double) {
        seek(duration: duration, direction: .forwards)
    }
    
    public func goBackwards(_ duration: Double) {
        seek(duration: duration, direction: .backwards)
    }
    
    public func showRecordingView(recording: Recording) {
        self.recording = recording
    }
}
