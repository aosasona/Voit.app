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
    @EnvironmentObject private var recordingManager: RecordingManager

    @StateObject var viewModel = RecordingListItemViewModel()
    @State var recording: Recording

    var statusBgColor: Color {
        return switch recording.status {
        case .pending:
            Color.yellow
        case .processing:
            Color.accent
        case .processed:
            Color.clear
        case .cancelled, .cancelling:
            Color.gray
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
        case .cancelled, .cancelling:
            Color.white
        case .processed:
            Color.clear
        }
    }

    var createdAt: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy HH:mm"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter.string(from: recording.createdAt)
    }

    var duration: String { recording.duration.format(.humanReadableDuration) ?? "0s" }

    var body: some View {
        Button(action: showExpandedView) {
            VStack {
                Text(recording.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .fontWeight(.bold)
                    .padding(.top, 1)

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
                    HStack {
                        if recording.status != .processed {
                            Text(recording.status.rawValue.uppercased())
                                .padding(.vertical, 1.5)
                                .padding(.horizontal, 4.0)
                                .font(.system(size: 9.0, weight: .medium))
                                .foregroundStyle(statusTextColor)
                                .background(RoundedRectangle(cornerRadius: 3.0, style: .circular).fill(statusBgColor))
                        }

                        Text("\(createdAt) · \(duration)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 1.0)
                }
            }
        }
        .task { viewModel.title = recording.title } // SwiftData saves on each keypress, I don't want that here
        .contextMenu {
            Button(action: { viewModel.isEditing = true }) { Label("Rename", systemImage: "pencil") }
            Button(action: { transcriptionEngine.enqueue(recording, retranscribe: true) }) { Label("Re-transcribe", systemImage: "arrow.clockwise") }
            Button(action: {}) { Label("Details", systemImage: "info.circle") }
        }
        .fullScreenCover(isPresented: $viewModel.showFullScreen) {
            ExpandedRecordingView(recording: $recording, dismiss: { viewModel.toggleFullScreen() })
        }
        .alert("Rename recording", isPresented: $viewModel.isEditing) {
            TextField("Enter a title", text: $viewModel.title)
            Button("Save", action: saveTitle)
            Button("Cancel", role: .cancel) {}
        }
        .swipeActions(allowsFullSwipe: false) {
            if recording.status == .processing {
                Button(role: .cancel, action: cancel) {
                    Label("Cancel", systemImage: "xmark")
                }
                .tint(.red)
            } else {
                Button(role: .destructive, action: deleteRecording) {
                    Label("Delete", systemImage: "trash.fill")
                }
                .tint(.red)
                .disabled(recording.status == .cancelling)

                Button(action: {}) {
                    Label("Move to...", systemImage: "folder.fill")
                }.tint(.indigo)
            }
        }
        .buttonStyle(RecordingListItemStyle())
    }

    func showExpandedView() {
        if recording.transcript != nil {
            viewModel.toggleFullScreen()
        }
    }

    private func cancel() {
        do {
            try transcriptionEngine.cancel(recording)
        } catch {}
    }

    private func saveTitle() {
        recording.title = viewModel.title
    }

    private func deleteRecording() {
        // Prevent deletion of a recording that is already being processed
        do {
            if recording.status == .processing { return }
            transcriptionEngine.dequeue(recording)
            defer { modelContext.delete(recording) }

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
        RecordingListItem(recording: recording)
    }
}

#Preview {
    RecordingListItemPreview()
}
