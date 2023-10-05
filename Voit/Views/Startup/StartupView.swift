//
//  SetupView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 04/10/2023.
//

import ActivityIndicatorView
import SwiftUI

struct SetupView: View {
    @EnvironmentObject private var transcriptionEngine: TranscriptionEngine

    @State private var showActivityIndicatorView = true
    @State private var showErrorAlert = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(gradient: Gradient(colors: [.accent, .black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .ignoresSafeArea()

            VStack(alignment: .center) {
                Spacer()

                ActivityIndicatorView(isVisible: $showActivityIndicatorView, type: .growingArc(.accent, lineWidth: 5.0))
                    .frame(width: 50.0, height: 50.0)

                Spacer()

                Text("This only has to be done once and may take a few seconds...")
                    .foregroundStyle(.white.opacity(0.3))
                    .multilineTextAlignment(.center)
                    .font(.caption2)
                    .padding(.horizontal)
                    .padding(.bottom, 16.0)
            }
        }
        .task { setup() }
        .alert("Startup failed", isPresented: self.$showErrorAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Failed to initialize model, try restarting the app. If this issue persists, please contact us at contact@wyte.space.")
        }
    }

    private func setup() {
        do {
            try transcriptionEngine.initContext()
        } catch {
            showErrorAlert = true
        }
    }
}

#Preview {
    SetupView()
}
