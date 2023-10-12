//
//  RecordingListItem.swift
//  Voit
//
//  Created by Ayodeji Osasona on 07/10/2023.
//

import SwiftUI

struct RecordingListItem: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var transcriptionEngine: TranscriptionEngine

    @State private var isEditing: Bool = false
    @State var recording: Recording
    @State var title: String = ""

    var statusBgColor: Color {
        return switch recording.status {
        case .pending:
            Color.yellow
        case .processing:
            Color.accent
        case .processed:
            Color.clear
        case .failed:
            Color.red
        }
    }

    var statusTextColor: Color {
        return switch recording.status {
        case .pending:
            Color.black
        case .processing:
            Color.white
        case .failed:
            Color.white
        case .processed:
            Color.clear
        }
    }

    var body: some View {
        VStack {
            Text(recording.title)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                if recording.status != .processed {
                    Text(recording.status.rawValue.uppercased())
                        .padding(.vertical, 1.5)
                        .padding(.horizontal, 4.0)
                        .font(.system(size: 9.0, weight: .medium))
                        .foregroundStyle(statusTextColor)
                        .background(RoundedRectangle(cornerRadius: 3.0, style: .circular).fill(statusBgColor))
                }

                if let duration = recording.duration.format(.humanReadableDuration) {
                    Text(duration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(recording.createdAt.formatted())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 1.0)
        }
        .task { title = recording.title }
        .contextMenu {
            Button(action: { isEditing = true }) { Label("Rename", systemImage: "pencil") }
        }
        .alert("Rename recording", isPresented: $isEditing) {
            TextField("Enter a title", text: $title)
            Button("Save", action: save)
            Button("Cancel", role: .cancel) {}
        }
        .swipeActions(allowsFullSwipe: false) {
            Button(role: .destructive, action: deleteRecording) {
                Label("Delete", systemImage: "trash.fill")
            }
            .tint(.red)
            .disabled(recording.status == .processing)

            Button(action: {}) {
                Label("Move to...", systemImage: "folder.fill")
            }.tint(.indigo)
        }
    }

    private func save() {
        recording.title = title
    }

    private func deleteRecording() {
        // Prevent deletion of a recording that is already being processed
        if recording.status == .processing { return }
        DispatchQueue.main.async { transcriptionEngine.dequeue(recording) }
        defer { modelContext.delete(recording) }

        do {
            guard let path = recording.path else { return }
            try FileSystem.deleteFile(path: path)
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct RecordingListItemStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled && !configuration.isPressed ? 1.0 : 0.5)
    }
}

struct RecordingListItemPreview: View {
    @State var recording = Recording(title: "Lorem ipsum dolor", path: URL(fileURLWithPath: ""))

    var body: some View {
        RecordingListItem(recording: recording)
    }
}

#Preview {
    RecordingListItemPreview()
}
