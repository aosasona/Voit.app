//
//  RecordingManager.swift
//  Voit
//
//  Created by Ayodeji Osasona on 21/10/2023.
//

import AudioKit
import AVFoundation
import Combine
import Foundation
import MediaPlayer
import SwiftUI

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
    
    @AppStorage(AppStorageKey.skipForward.rawValue) var skipForward: Int = 5
    @AppStorage(AppStorageKey.skipBack.rawValue) var skipBack: Int = 5
    public let player = AVPlayer()
    private let audioSession = AVAudioSession.sharedInstance()
    
    @Published public var recording: Recording? = nil
    @Published public var isPlaying: Bool = false
    @Published public var playbackSpeed: Double = 1.0
    
    private func setupRTC() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { _ in
            if !self.isPlaying {
                self.play()
                return .success
            }
            
            return .commandFailed
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { _ in
            if self.isPlaying {
                self.pause()
                return .success
            }
            
            return .commandFailed
        }
        
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.preferredIntervals = [NSNumber(value: skipForward)]
        commandCenter.skipForwardCommand.addTarget { _ in
            self.goForwards(Double(self.skipForward))
            return .success
        }
        
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [NSNumber(value: skipBack)]
        commandCenter.skipBackwardCommand.addTarget { _ in
            self.goBackwards(Double(self.skipForward))
            return .success
        }
    }
    
    private func registerNowPlaying() {
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = recording?.title ?? "Voit audio"
        if let url = recording?.path {
            info[MPNowPlayingInfoPropertyAssetURL] = url
        }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentItem?.currentTime().seconds ?? 0.0
        info[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.duration.seconds ?? recording?.duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = playbackSpeed
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    public func load(recording: Recording) throws {
        self.recording = recording
        
        if let url = self.recording?.path {
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
        } else {
            throw RecordingManagerError.noUrlPresent
        }
        
        try? audioSession.setCategory(.playback)
        try? audioSession.setActive(true)
        
        registerNowPlaying()
        setupRTC()
    }
    
    public func play() {
        isPlaying.toggle()
        player.play()
    }
    
    public func pause() {
        isPlaying.toggle()
        player.pause()
    }
    
    public func setPlaybackSpeed(speed: Double) {
        playbackSpeed = speed
    }
    
    private func seek(_ seekDuration: Double, direction: SeekDirection) {
        let target: Double
        let totalDuration = player.currentItem?.duration.seconds ?? recording?.duration ?? 0
        let currentDuration = player.currentItem?.currentTime().seconds ?? 0
        if direction == .forwards {
            target = min(currentDuration + seekDuration, totalDuration)
        } else {
            target = max(currentDuration - seekDuration, 0.0)
        }
        
        let targetCMTime = CMTime(seconds: target, preferredTimescale: CMTimeScale(1))
        player.seek(to: targetCMTime)
        
        if !isPlaying {
            player.play()
        }
    }
    
    public func goForwards(_ duration: Double) {
        seek(duration, direction: .forwards)
    }
    
    public func goBackwards(_ duration: Double) {
        seek(duration, direction: .backwards)
    }
    
    public func showRecordingView(recording: Recording) {
        self.recording = recording
    }
}
