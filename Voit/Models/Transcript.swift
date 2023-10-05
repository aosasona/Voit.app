//
//  Transcript.swift
//  Voit
//
//  Created by Ayodeji Osasona on 05/10/2023.
//

import Foundation
import SwiftData
import SwiftWhisper

// This has been reimplemented to prevent dependence on the SwiftWhisper package in the future should it need to be removed - although the transformation might indeed be expensive
@Model
final class TranscriptSegment {
    public let id: UUID
    public let text: String
    public let startTime: Int
    public let endTime: Int
    
    init(text: String, startTime: Int, endTime: Int) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
    }
}

@Model
final class Transcript {
    @Attribute(.unique) var id: UUID
    @Relationship() private var segments: [TranscriptSegment]
    
    init(segments: [TranscriptSegment]) {
        self.id = UUID()
        self.segments = segments
    }
}
