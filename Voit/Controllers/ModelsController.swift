//
//  WhisperModelController.swift
//  Voit
//
//  Created by Ayodeji Osasona on 04/10/2023.
//

import Foundation

enum WhisperModels: String, CaseIterable, Identifiable {
    case tiny
    case base
    
    var id: Self { self }
}

final class ModelsController {
    public var modelsDirectory: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return URL(fileURLWithPath: "models", isDirectory: true, relativeTo: documentDirectory)
    }
    
    public var bundledModelsArchive: URL? {
        return Bundle.main.url(forResource: "models", withExtension: "zip")
    }
}
