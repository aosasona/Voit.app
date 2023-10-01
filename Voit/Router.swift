//
//  Router.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

final class Router: ObservableObject {
    @Published var path = NavigationPath()

    enum Screen: Codable, Hashable {
        case Home
        case Settings
    }

    enum Destination: Codable, Hashable {
        case Root
        case Back
        case Screen(Screen)
    }

    func navigate(_ to: Destination) {
        switch to {
        case let .Screen(screen):
            path.append(screen)
        case .Back:
            path.removeLast()
        case .Root:
            path.removeLast(path.count)
        }
    }
}
