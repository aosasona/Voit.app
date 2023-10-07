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
    enum Status: Codable {
        case pending
        case failed
        case processing
    }
    
    @Attribute(.unique) let id: UUID
    var title: String
    var path: URL /// The URL to the path where the copied file lives (in the user land)
    var status: Status
    var createdAt: Date
    var lastModifiedAt: Date
    
    var folder: Folder?
    
    @Relationship(deleteRule: .cascade, inverse: \Transcript.recording)
    var transcript: Transcript?
    
    init(title: String, path: URL, transcript: Transcript? = nil, status: Status = .pending) {
        self.id = UUID()
        self.title = title
        self.path = path
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
