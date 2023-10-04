//
//  SetupStatusView.swift
//  Voit
//
//  Created by Ayodeji Osasona on 04/10/2023.
//

import ProgressIndicatorView
import SwiftUI

struct SetupStatusView: View {
    @State private var showProgressIndicator = true

    @Binding var progress: CGFloat
    @Binding var status: SetupStatus

    var body: some View {
        VStack {
            Spacer()
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

    private func getStatusText() -> String {
        return switch self.status {
        case .starting:
            "Starting setup..."
        case .unpacking:
            "Extracting models from archive"
        case .done:
            "Setup complete"
        }
    }
}

struct ContentView: View {
    @State private var dummyProgress: CGFloat = 0.25
    @State private var dummyStatus: SetupStatus = .unpacking

    var body: some View {
        ZStack {
            Rectangle().fill(.black).ignoresSafeArea()
            SetupStatusView(progress: self.$dummyProgress, status: self.$dummyStatus)
        }
    }
}

#Preview {
    ContentView()
}
