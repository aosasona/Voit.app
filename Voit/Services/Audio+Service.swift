//
//  AudioService.swift
//  Voit
//
//  Created by Ayodeji Osasona on 05/10/2023.
//

import AudioKit
import Foundation

final class AudioService {
    static let fileManager = FileManager()

    public static func convertToPCMArray(input: URL, completionHandler: @escaping (Result<[Float], Error>) -> Void) {
        var opts = FormatConverter.Options()
        opts.format = .wav
        opts.sampleRate = 16000
        opts.bitDepth = 16
        opts.channels = 1
        opts.isInterleaved = false

        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let converter = FormatConverter(inputURL: input, outputURL: tempURL, options: opts)
        converter.start { err in
            if let err {
                completionHandler(.failure(err))
                return
            }

            var data: Data

            do {
                data = try Data(contentsOf: tempURL)
            } catch {
                completionHandler(.failure(error))
                return
            }

            do {
                let floats = stride(from: 44, to: data.count, by: 2).map { r in
                    data[r ..< r + 2].withUnsafeBytes { bufPointer in
                        let short = Int16(littleEndian: bufPointer.load(as: Int16.self))
                        return max(-1.0, min(Float(short) / 32767.0, 1.0))
                    }
                }

                try FileManager.default.removeItem(at: tempURL)

                completionHandler(.success(floats))
                return
            } catch {
                completionHandler(.failure(error))
                return
            }
        }
    }

    public static func importFile(file source: URL, folder: Folder? = nil) throws -> Recording? {
        if !FileSystem.exists(.recordings) { try? makeRecordingsDirectory() }
        guard let copiedFileURL = try? FileSystem.copyFile(from: source, targetDir: .recordings) else { return nil }
        let recording = Recording(title: source.deletingPathExtension().lastPathComponent, path: copiedFileURL, folder: folder)
        return recording
    }

    private static func makeRecordingsDirectory() throws {
        _ = try? FileSystem.mkdirp(in: .document, path: FileSystem.Directory.recordings.rawValue)
    }
}
