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
                files.forEach { file in
                    let gotAccess = file.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    guard let modelUrl = ModelController.getModelURL(WhisperModel.tiny) else { return }
                    let params = WhisperParams(strategy: .greedy)
                    params.language = .auto
                    let ctx = Whisper(fromFileURL: modelUrl, withParams: params)

                    AudioController.convertToPCMArray(input: file) { result in
                        switch result {
                        case .success(let frames):
                            ctx.transcribe(audioFrames: frames) { transcriptionResult in
                                switch transcriptionResult {
                                case .success(let segments):
                                    print(segments)
                                    return
                                case .failure(let e):
                                    print(e.localizedDescription)
                                    showErrorAlert = true
                                    errorMessage = "Transcription failed, please try again"
                                }
                            }
                        case .failure(let e):
                            print(e.localizedDescription)
                            showErrorAlert = true
                            errorMessage = "Unable to convert audio to required format"
                        }
                    }
                }
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
}

#Preview {
    AddRecordingView()
}
