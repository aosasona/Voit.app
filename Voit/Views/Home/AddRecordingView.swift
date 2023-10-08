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

        DispatchQueue.global().async {
            files.forEach { file in
                if !file.startAccessingSecurityScopedResource() {
                    triggerError("Unable to access selected file, please try again", fromExternalQueue: true)
                    return
                }
                defer { file.stopAccessingSecurityScopedResource() }

                do {
                    guard let recording = try AudioService.importFile(file: file, folder: folder) else {
                        triggerError("Failed to create new recording from \(file.lastPathComponent)", fromExternalQueue: true)
                        return
                    }
                    DispatchQueue.main.async {
                        transcriptionEngine.enqueue(recording)
                        context.insert(recording)
                    }
                } catch FileSystem.FSError.failedToGetDocumentDir {
                    // if this ever happens, just crash the app and make the user launch it again
                    fatalError("Failed to get document directory: this should have never happened")
                } catch {
                    triggerError("Failed to import file: \(file.lastPathComponent)", fromExternalQueue: true)
                }
            }

            DispatchQueue.main.async { transcriptionEngine.hasImportedFiles() }
        }
    }

    private func triggerError(_ message: String) {
        showErrorAlert = true
        errorMessage = message
    }

    private func triggerError(_ message: String, fromExternalQueue: Bool = false) {
        DispatchQueue.main.async {
            triggerError(message)
        }
    }
}

#Preview {
    AddRecordingView()
}
