//
//  Router.swift
//  Voit
//
//  Created by Ayodeji Osasona on 01/10/2023.
//

import SwiftUI

final class Router: ObservableObject {
    public enum Settings: Codable, Hashable {
        case root
    }

    public enum Screen: Codable, Hashable {
        case home
        case settings(Settings)
    }

    @Published var path = NavigationPath()

    func navigate(to destination: Screen) {
        self.path.append(destination)
    }

    func goBack() {
        self.path.removeLast()
    }

    func goToRoot() {
        self.path.removeLast(path.count)
    }
}
