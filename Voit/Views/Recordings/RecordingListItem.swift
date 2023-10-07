//
//  RecordingListItem.swift
//  Voit
//
//  Created by Ayodeji Osasona on 07/10/2023.
//

import SwiftUI

struct RecordingListItem: View {
    @EnvironmentObject private var router: Router
    var recording: Recording

    var statusBgColor: Color {
        return switch recording.status {
        case .pending:
            Color.yellow
        case .failed:
            Color.red
        case .processed:
            Color.clear
        }
    }
    
    var statusTextColor: Color {
        return switch recording.status {
        case .pending:
            Color.black
        case .failed:
            Color.white
        case .processed:
            Color.clear
        }
    }

    var body: some View {
        Button(action: { router.navigate(to: .recording(recording.id)) }) {
            VStack(alignment: .leading) {
                Text(recording.title)
                HStack {
                    Text(recording.status.rawValue.uppercased())
                        .padding(.vertical, 1.5)
                        .padding(.horizontal, 4.0)
                        .font(.system(size: 9.0, weight: .medium))
                        .foregroundStyle(statusTextColor)
                        .background(RoundedRectangle(cornerRadius: 3.0, style: .circular).fill(statusBgColor))

                    Text(recording.createdAt.formatted())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 1.0)
                }
            }
            .padding(.vertical, 3.0)
        }
        .buttonStyle(RecordingListItemStyle())
    }
}

struct RecordingListItemStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled ? 1.0 : 0.5)
    }
}

#Preview {
    RecordingListItem(recording: Recording(title: "Lorem ipsum dolor", path: URL(fileURLWithPath: "")))
}
