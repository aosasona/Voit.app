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
        case failed
        case processing
        case processed
    }
    
    @Attribute(.unique) let id: UUID
    var title: String
    /// The URL to the path where the copied file lives (in the user land)
    var filename: String
    var status: Status
    var locked: Bool = false
    var createdAt: Date
    var lastModifiedAt: Date
    
    var folder: Folder?
    
    @Relationship(deleteRule: .cascade, inverse: \Transcript.recording)
    var transcript: Transcript?
    
    var path: URL? {
        guard let userDirectory = FileSystem.documentDirectory else { return nil }
        return userDirectory.appending(path: FileSystem.Directory.recordings.rawValue).appending(path: self.filename)
    }
    
    init(title: String, path: URL, folder: Folder? = nil, transcript: Transcript? = nil, locked: Bool = false, status: Status = .pending) {
        self.id = UUID()
        self.title = title
        self.filename = path.lastPathComponent
        self.locked = locked
        self.status = status
        self.createdAt = .now
        self.lastModifiedAt = .now
        
        self.transcript = transcript
    }
    
    func update<T>(keyPath: ReferenceWritableKeyPath<Recording, T>, to value: T) {
        self[keyPath: keyPath] = value
        lastModifiedAt = .now
    }
}
