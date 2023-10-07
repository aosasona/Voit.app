//
//  ModelService.swift
//  Voit
//
//  Created by Ayodeji Osasona on 04/10/2023.
//

import Foundation
import SwiftUI
import SwiftWhisper

protocol ModelProtocol {
    func getName() -> String
}

enum WhisperModel: String, Identifiable, ModelProtocol {
    case tiny
    case base

    var id: Self { self }

    func getName() -> String { return self.rawValue }
}

final class ModelService: ObservableObject {
    @AppStorage(AppStorageKey.selectedModel.rawValue) var selectedModel: WhisperModel = .tiny
    @AppStorage(AppStorageKey.selectedLanguage.rawValue) var selectedLanguage: WhisperLanguage = .auto

    public var model: WhisperModel { return selectedModel }
    public var language: WhisperLanguage { return selectedLanguage }
    
    public var modelsDirectory: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return URL(fileURLWithPath: "models", isDirectory: true, relativeTo: documentDirectory)
    }

    public var bundledModelsArchive: URL? {
        return Bundle.main.url(forResource: "models", withExtension: "zip")
    }

    public static func getModelURL(_ model: ModelProtocol) -> URL? {
        return Bundle.main.url(forResource: model.getName(), withExtension: "bin")
    }
    
}
