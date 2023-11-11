//
//  PressableButtonStyle.swift
//  Voit
//
//  Created by Ayodeji Osasona on 11/11/2023.
//

import Foundation
import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor((configuration.isPressed || !isEnabled) ? .white.opacity(0.6) : .white)
            .clipShape(RoundedRectangle(cornerSize: .zero))
            .scaleEffect(configuration.isPressed && self.isEnabled ? 0.90 : 1)
            .animation(.easeInOut(duration: 0.05), value: configuration.isPressed && self.isEnabled)
    }
}

#Preview {
    VStack {
        Button("Enabled") {}
            .buttonStyle(PressableButtonStyle())

        Button("Disabled") {}
            .buttonStyle(PressableButtonStyle())
            .disabled(true)
    }
}
