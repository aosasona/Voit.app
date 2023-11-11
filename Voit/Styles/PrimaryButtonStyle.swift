//
//  VoitButton.swift
//  Voit
//
//  Created by Ayodeji Osasona on 04/10/2023.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal)
            .font(.body.weight(.semibold))
            .background(!self.isEnabled ? .accent.opacity(0.5) : configuration.isPressed ? .accent.opacity(0.75) : .accent)
            .foregroundColor(self.isEnabled ? .white : .white.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 12.0))
            .scaleEffect(configuration.isPressed && self.isEnabled ? 0.95 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed && self.isEnabled)
    }
}

#Preview {
    VStack {
        Button("Enabled") {}
            .buttonStyle(PrimaryButtonStyle())

        Button("Disabled") {}
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
    }
}
