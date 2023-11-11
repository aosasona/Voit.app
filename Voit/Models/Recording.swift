//
//  Recording.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import Foundation
import SwiftData

@Model
final class Recording {
    enum Status: String, Codable {
        case pending
        case processing
        case failed
        case processed
        case cancelled
        case cancelling
    }
    
    @Attribute(.unique) let id: UUID = UUID()
    var title: String
    /// The filename of the file eg. something.mp3 - Apple changes the container UUID from time to time so you can't save the full URL
    var filename: String
    var author: String?
    /// duration of the recording in seconds
    var duration: Double = 0.0
    var locked: Bool = false
    var createdAt: Date
    var lastModifiedAt: Date
    var failedAttempts: Int = 0
    
    var folder: Folder?
    
    @Relationship(deleteRule: .cascade, inverse: \Transcript.recording)
    var transcript: Transcript?
    
    @Attribute var _status: Status.RawValue = Status.pending.rawValue
    @Transient var status: Status {
        get { Status(rawValue: _status)! }
        set { _status = newValue.rawValue }
    }
    
    var path: URL? {
        guard let recordingDirectory = FileSystem.getDirectoryURL(.recordings) else { return nil }
        return recordingDirectory.appending(path: filename)
    }
    
    init(title: String, path: URL, folder: Folder? = nil, transcript: Transcript? = nil, duration: Double = 0.0, locked: Bool = false, status: Status = .pending) {
        self.title = title
        self.filename = path.lastPathComponent
        self.duration = duration
        self.locked = locked
        self._status = status.rawValue
        self.createdAt = .now
        self.lastModifiedAt = .now
        
        self.transcript = transcript
    }
    
    func update<T>(keyPath: ReferenceWritableKeyPath<Recording, T>, to value: T) {
        self[keyPath: keyPath] = value
        lastModifiedAt = .now
    }
}
