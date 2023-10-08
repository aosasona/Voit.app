//
//  FileSystem.swift
//  Voit
//
//  Created by Ayodeji Osasona on 07/10/2023.
//

import Foundation

final class FileSystem {
    enum Directory: String {
        case document
        case recordings
    }

    enum FileExtension {
        case audio
    }

    enum FSError: Error {
        case failedToGetDocumentDir
        case unableToGetParentDir
    }

    static var documentDirectory: URL? {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first
    }

    public static func exists(_ dir: Directory) -> Bool {
        guard let url = getDirectoryURL(dir) else { return false }
        var isDirectory: ObjCBool = true
        return FileManager.default.fileExists(atPath: url.relativePath, isDirectory: &isDirectory)
    }

    public static func getDirectoryURL(_ directory: Directory) -> URL? {
        switch directory {
        case .document:
            return documentDirectory
        case .recordings:
            guard let dir = documentDirectory else { return nil }
            return dir.appending(path: Directory.recordings.rawValue)
        }
    }

    /// Create the directory and its parent directories - operates in user's document directory
    public static func mkdirp(in: Directory, path: String) throws -> URL {
        guard let dir = documentDirectory else { throw FileSystem.FSError.failedToGetDocumentDir }
        let target = dir.appending(path: path)
        try? FileManager.default.createDirectory(at: target, withIntermediateDirectories: true)
        return target
    }

    /// Copy file from a URL to a user-land directory using a generated name (UUID)
    public static func copyFile(from: URL, targetDir: Directory) throws -> URL {
        let filename = UUID().uuidString + "." + from.pathExtension
        guard let dirURL = getDirectoryURL(targetDir) else { throw FileSystem.FSError.unableToGetParentDir }
        let target = dirURL.appending(path: filename)
        try? FileManager.default.copyItem(at: from, to: target)
        return target
    }

    public static func deleteFile(path: URL) throws {
        try? FileManager.default.removeItem(at: path)
    }
}
