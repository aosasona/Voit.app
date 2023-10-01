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
        case Pending
        case Failed
        case Processing
    }
    
    @Attribute(.unique) var id: UUID
    var title: String
    var status: Status
    var createdAt: Date
    var updatedAt: Date
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.status = .Pending
        self.createdAt = Date.now
        self.updatedAt = Date.now
    }
}
