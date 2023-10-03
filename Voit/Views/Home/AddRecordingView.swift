//
//  AddRecordingView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

struct AddRecordingView: View {
    @State private var importing: Bool = false

    var body: some View {
        Button(action: { importing = true }) {
            Image(systemName: "plus")
                .padding([.all], 8)
                .font(.title3)
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.audio]) { result in
            switch result {
            case .success(let url):
                print(url.absoluteString)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    AddRecordingView()
}
