//
//  Folder.swift
//  Voit
//
//  Created by Ayodeji Osasona on 06/10/2023.
//

import Foundation
import SwiftData

@Model
final class Folder {
    @Attribute(.unique) let id: UUID
    var name: String
    let createdAt: Date
    var lastModifiedAt: Date
    
    var tags = [String]()
    
    @Relationship(deleteRule: .cascade, inverse: \Recording.folder)
    var recordings = [Recording]()
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.createdAt = .now
        self.lastModifiedAt = .now
        self.tags = []
    }
    
    func update<T>(keyPath: ReferenceWritableKeyPath<Folder, T>, to value: T) {
        self[keyPath: keyPath] = value
        lastModifiedAt = .now
    }
}
