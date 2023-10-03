//
//  AddRecordingView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

struct AddRecordingView: View {
    @State private var importing: Bool = false
    @State private var showErrorAlert: Bool = false

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
                }
            case .failure(let error):
                showErrorAlert = true
                print(error.localizedDescription)
            }
        }
        .alert("Failed to import file, please try again. Report this as a bug if this issue persists!", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

#Preview {
    AddRecordingView()
}
