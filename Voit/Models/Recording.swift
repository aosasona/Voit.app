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
        case processed
    }
    
    @Attribute(.unique) let id: UUID
    var title: String
    /// The URL to the path where the copied file lives (in the user land)
    var path: URL
    var status: Status
    var locked: Bool = false
    var createdAt: Date
    var lastModifiedAt: Date
    
    var folder: Folder?
    
    @Relationship(deleteRule: .cascade, inverse: \Transcript.recording)
    var transcript: Transcript?
    
    init(title: String, path: URL, locked: Bool = false, transcript: Transcript? = nil, status: Status = .pending) {
        self.id = UUID()
        self.title = title
        self.path = path
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
