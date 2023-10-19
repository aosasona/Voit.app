//
//  ExpandedRecordingView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 19/10/2023.
//

import SwiftUI

struct ExpandedRecordingView: View {
    @Binding var recording: Recording
    var body: some View {
        ZStack {
            ScrollView {
                if let transcript = recording.transcript {
                    Text(transcript.asText())
                        .font(.system(size: 18).weight(.medium))
                        .lineLimit(nil)
                        .lineSpacing(3.0)
                        .multilineTextAlignment(.leading)
                        .padding()
                } else {
                    Text("Nothing yet")
                        .padding()
                }
            }
            .safeAreaPadding(.vertical)
        }
    }
}

struct ExpandedRecordingPreview: View {
    @State var recording = Recording(title: "Lorem ipsum dolor 1", path: URL(fileURLWithPath: ""), transcript: Transcript(segments: [TranscriptSegment(text: "This is a test", startTime: 5, endTime: 6)]))

    var body: some View {
        ExpandedRecordingView(recording: $recording)
    }
}

#Preview {
    ExpandedRecordingPreview()
}
