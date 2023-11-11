//
//  AddRecordingView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import AudioKit
import SwiftUI
import SwiftWhisper

struct AddRecordingView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var transcriptionEngine: TranscriptionEngine

    @AppStorage(AppStorageKey.importBehaviour.rawValue) var importBehaviour: ImportBehaviour = .copy

    var currentFolder: Folder? = nil
    @State private var importing: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = "Failed to import file, please try again. Report this as a bug if this issue persists!"

    var body: some View {
        Button(action: { importing = true }) {
            Image(systemName: "plus")
                .padding([.all], 8)
                .font(.title3)
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.audio], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let files):
                handleMultipleImports(files: files, folder: currentFolder)
            case .failure(let error):
                showErrorAlert = true
                print(error.localizedDescription)
            }
        }
        .alert("Import failed", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text(errorMessage)
        }
    }

    private func handleMultipleImports(files: [URL], folder: Folder?) {
        transcriptionEngine.isImportingFiles()

        let importQueue = DispatchQueue(label: "queue.import", attributes: .concurrent)
        let group = DispatchGroup()

        files.forEach { file in
            group.enter()
            importQueue.async(group: group) {
                Task {
                    if !file.startAccessingSecurityScopedResource() {
                        triggerError("Unable to access selected file, please try again", fromExternalQueue: true)
                        group.leave()
                        return
                    }
                    defer { file.stopAccessingSecurityScopedResource() }

                    do {
                        guard let recording = try await AudioService.importFile(file: file, folder: folder, importBehaviour: importBehaviour) else {
                            triggerError("Failed to create new recording from \(file.lastPathComponent)", fromExternalQueue: true)
                            group.leave()
                            return
                        }

                        DispatchQueue.main.async {
                            context.insert(recording)
                            transcriptionEngine.enqueue(recording)
                        }

                        group.leave()
                        return
                    } catch FileSystem.FSError.failedToGetDocumentDir {
                        triggerError("Failed to get document directory: this should have never happened")
                        group.leave()
                    } catch AudioService.ImportError.unableToDetermineDuration {
                        triggerError("Failed to extract metadata for \(file.lastPathComponent), skipping...")
                        group.leave()
                    } catch {
                        triggerError("Failed to import file: \(file.lastPathComponent)", fromExternalQueue: true)
                        group.leave()
                    }
                }
            }
        }

        group.notify(queue: DispatchQueue.main) {
            transcriptionEngine.hasImportedFiles()
        }
    }

    private func triggerError(_ message: String) {
        showErrorAlert = true
        errorMessage = message
    }

    private func triggerError(_ message: String, fromExternalQueue: Bool = false) {
        if fromExternalQueue {
            DispatchQueue.main.async { triggerError(message) }
            return
        }

        triggerError(message)
    }
}

#Preview {
    AddRecordingView()
}
