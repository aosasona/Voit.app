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

    @StateObject var viewModel = RecordingListItemViewModel()
    @State var recording: Recording

    let expand: () -> Void

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

    var footerText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        var footer = dateFormatter.string(from: recording.createdAt)

        if let duration = recording.duration.format(.humanReadableDuration) {
            footer += " • \(duration)"
        }

        return footer
    }

    var body: some View {
        VStack {
            Text(recording.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(2)
                .fontWeight(.bold)

            if let transcript = recording.transcript {
                Text(transcript.asText().trimmingCharacters(in: .whitespacesAndNewlines))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 1)
            }

            HStack {
                if recording.status != .processed {
                    Text(recording.status.rawValue.uppercased())
                        .padding(.vertical, 1.5)
                        .padding(.horizontal, 4.0)
                        .font(.system(size: 9.0, weight: .medium))
                        .foregroundStyle(statusTextColor)
                        .background(RoundedRectangle(cornerRadius: 3.0, style: .circular).fill(statusBgColor))
                }

                Text("\(footerText)")
                    .font(.caption)
                    .padding(.horizontal, 0)
                    .foregroundStyle(.secondary.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 1.0)
        }
        .task { viewModel.title = recording.title } // SwiftData saves on each keypress, I don't want that here
        .onTapGesture { expand() }
        .contextMenu {
            Button(action: { viewModel.isEditing = true }) { Label("Rename", systemImage: "pencil") }
        }
        .alert("Rename recording", isPresented: $viewModel.isEditing) {
            TextField("Enter a title", text: $viewModel.title)
            Button("Save", action: saveTitle)
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

    private func saveTitle() {
        recording.title = viewModel.title
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
    @State var recording = Recording(title: "Lorem ipsum dolor 1", path: URL(fileURLWithPath: ""), transcript: Transcript(segments: [TranscriptSegment(text: "This is a test", startTime: 5, endTime: 6)]))
    
    var body: some View {
        RecordingListItem(recording: recording, expand: {})
    }
}

#Preview {
    RecordingListItemPreview()
}
