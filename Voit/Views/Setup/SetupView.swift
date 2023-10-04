//
//  SetupView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 04/10/2023.
//

import ProgressIndicatorView
import SwiftUI

enum SetupStatus: Int, CaseIterable {
    case starting = 0
    case unpacking
    case cleanup
    case done

    var index: CGFloat {
        return CGFloat(integerLiteral: rawValue)
    }
}

struct SetupView: View {
    private var whisperModelController = WhisperModelController()
    @AppStorage("hasDownloadedDefaultModel") var hasDownloadedDefaultModel: Bool = false

    @State private var showProgressIndicator = true
    @State private var showErrorAlert = false
    @State private var status: SetupStatus = .starting
    @State private var progress: CGFloat = 0.0

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [.accent, .black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .ignoresSafeArea()

            VStack(alignment: .center) {
                    Spacer()
                
                if self.status == .done {
                    Button("Get Started") {
                        self.hasDownloadedDefaultModel = true
                    }
                    .buttonStyle(PrimaryButton())
                    .padding()
                } else {
                    VStack {
                        ProgressIndicatorView(
                            isVisible: self.$showProgressIndicator,
                            type: .circle(progress: self.$progress, lineWidth: 5.0, strokeColor: .accent, backgroundColor: .accent.opacity(0.25))
                        )
                        .frame(width: 44.0, height: 44.0)

                        withAnimation {
                            Text(self.getStatusText())
                                .font(.system(size: 14.0, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding()
                        }
                    }

                    Spacer()

                    Text("This only has to be done once and may take a few minutes...")
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .font(.caption2)
                        .padding(.horizontal)
                        .padding(.bottom, 10.0)
                }
            }
        }
        .task { self.setup() }
        .alert("Setup failed", isPresented: self.$showErrorAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Failed to complete setup, try restarting the app again. If this issue persists, please contact us at contact@wyte.space.")
        }
    }

    private func updateStatus(_ newStatus: SetupStatus) {
        self.status = newStatus
        self.progress = newStatus.index / CGFloat(integerLiteral: SetupStatus.allCases.count)
    }

    private func setup() {
        do {
            updateStatus(.starting)
            
            // models are intentionally left exposed so that users can replace the models with any one they want
            let modelsArchiveURL = URL(fileURLWithPath: "models.zip", isDirectory: false, relativeTo: whisperModelController.modelsDirectory)
            guard let bundledModelsArchiveURL = whisperModelController.bundledModelsArchive else {
                print("Could not find models.zip in bundle")
                return
            }

            let fileManager = FileManager()
            try fileManager.createDirectory(at: self.whisperModelController.modelsDirectory, withIntermediateDirectories: true)

            self.updateStatus(.unpacking)

        } catch {
            self.showErrorAlert = true
            print(error.localizedDescription)
        }
    }

    private func getStatusText() -> String {
        return switch self.status {
        case .starting:
            "Starting setup..."
        case .unpacking:
            "Extracting models from archive"
        case .cleanup:
            "Cleaning up"
        case .done:
            "Setup complete"
        }
    }
}

#Preview {
    SetupView()
}
