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
    
    @Attribute(.unique) var id: UUID
    var title: String
    var status: Status
    var transcript: Transcript?
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.status = .pending
        self.transcript = nil
        self.createdAt = Date.now
        self.updatedAt = Date.now
    }
}
