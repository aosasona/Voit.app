//
//  RecordingView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 07/10/2023.
//

import SwiftUI

struct RecordingView: View {
    var recording: Recording

    var body: some View {
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

// #Preview {
//    RecordingView(recording: Recording(title: "something", path: URL() ))
// }
