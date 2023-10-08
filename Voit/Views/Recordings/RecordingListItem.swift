//
//  RecordingListItem.swift
//  Voit
//
//  Created by Ayodeji Osasona on 07/10/2023.
//

import SwiftUI

struct RecordingListItem: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject private var router: Router
    @State private var isEditing: Bool = false
    @State var recording: Recording
    @State var title: String = ""

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

            Button(action: {}) {
                Label("Move to...", systemImage: "folder.fill")
            }.tint(.indigo)
        }
        .buttonStyle(RecordingListItemStyle())
    }

    private func save() {
        recording.title = title
    }

    private func deleteRecording() {
        do {
            try FileSystem.deleteFile(path: recording.path)
            print(recording.path)
        } catch {
            print(error.localizedDescription)
        }
        modelContext.delete(recording)
    }
}

struct RecordingListItemStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(isEnabled ? 1.0 : 0.5)
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
