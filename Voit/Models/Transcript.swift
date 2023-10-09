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
    var text: String
    var startTime: Int
    var endTime: Int
    
    init(text: String, startTime: Int, endTime: Int) {
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
    }
}

@Model
final class Transcript {
    @Attribute(.unique) let id: UUID
    
    var recording: Recording?
    
    @Relationship(deleteRule: .cascade)
    private var segments: [TranscriptSegment] = []
    
    init(segments: [TranscriptSegment]) {
        self.id = UUID()
        self.segments = segments
    }
    
    public func asText() -> String {
        return self.segments.sorted(by: { a, b in a.startTime < b.startTime }).map(\.text).joined()
    }
}
