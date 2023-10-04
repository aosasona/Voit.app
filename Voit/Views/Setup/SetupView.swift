//
//  SetupView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 04/10/2023.
//

import SwiftUI
import Zip

enum SetupStatus: Int, CaseIterable {
    case starting = 0
    case unpacking
    case done

    var index: CGFloat {
        return CGFloat(integerLiteral: rawValue)
    }
}

struct SetupView: View {
    private var modelsController = ModelsController()

    @AppStorage("hasCompletedSetup") var hasCompletedSetup: Bool = false
    @AppStorage("hasUnpackedModels") var hasUnpackedModels: Bool = false
    @AppStorage("selectedModel") var selectedModel: String = ""
    
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
                if self.status == .done {
                    GetStartedView()
                } else {
                    SetupStatusView(progress: $progress, status: $status)
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
        status = newStatus
        progress = newStatus.index / CGFloat(integerLiteral: SetupStatus.allCases.count)
    }

    private func setup() {
        do {
            updateStatus(.starting)

            if (hasCompletedSetup || hasUnpackedModels) && selectedModel != "" {
                updateStatus(.done)
                return
            }

            guard let bundledModelsArchiveURL = modelsController.bundledModelsArchive else {
                print("Could not find models.zip in bundle")
                return
            }

            let fileManager = FileManager()
            try fileManager.createDirectory(at: modelsController.modelsDirectory, withIntermediateDirectories: true)

            updateStatus(.unpacking)
            // models are intentionally left exposed so that users can replace the models with anyone they want
            try Zip.unzipFile(bundledModelsArchiveURL, destination: modelsController.modelsDirectory, overwrite: true, password: nil, progress: { unzipProgress in
                var sectionProgressDiff: CGFloat = 0.0
                let mainProgressDiff: CGFloat = 1.0 / CGFloat(integerLiteral: SetupStatus.allCases.count)
                if unzipProgress > 0.0 {
                    if sectionProgressDiff <= 0.0 {
                        sectionProgressDiff = mainProgressDiff / unzipProgress
                    }
                    progress += sectionProgressDiff
                }
            })

            updateStatus(.done)
            hasUnpackedModels = true
        } catch {
            showErrorAlert = true
            print(error.localizedDescription)
        }
    }
}

#Preview {
    SetupView()
}
