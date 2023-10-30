//
//  ExpandedRecordingView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 19/10/2023.
//

import SwiftUI

struct ExpandedRecordingView: View {
    @Binding var recording: Recording
    public let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20)
                .fill(LinearGradient(colors: [.accent.opacity(0.4), .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                .ignoresSafeArea(.all)

            VStack {
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
            }
            
            Overlay()
        }
        .background(.ultraThinMaterial)
    }

    func Overlay() -> some View {
        VStack {
            HStack {
                Spacer()

                Button(action: dismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26.0))
                        .foregroundColor(.secondary.opacity(0.75))
                        .padding(3.0)
                }
            }
            .padding(.horizontal, 14.0)

            Spacer()
        }
    }
}

struct ExpandedRecordingPreview: View {
    @State var recording = Recording(title: "Lorem ipsum dolor 1", path: URL(fileURLWithPath: ""), transcript: Transcript(segments: [TranscriptSegment(text: "This is a test", startTime: 5, endTime: 6)]))

    var body: some View {
        ExpandedRecordingView(recording: $recording, dismiss: {})
    }
}

#Preview {
    ExpandedRecordingPreview()
}
