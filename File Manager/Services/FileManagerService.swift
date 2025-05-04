import UIKit
import Foundation

class FileManagerService: FileManagerServiceProtocol {
    private let fileManager = FileManager.default

    func contentsOfDirectory(at url: URL) -> [Content] {
        guard let items = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) else {
            return []
        }

        return items.map {
            let isDir = (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            return Content(name: $0.lastPathComponent, url: $0, type: isDir ? .folder : .file)
        }
    }

    func createDirectory(named name: String, at url: URL) throws {
        let newDirURL = url.appendingPathComponent(name)
        try fileManager.createDirectory(at: newDirURL, withIntermediateDirectories: true, attributes: nil)
    }

    func createFile(with image: UIImage, named name: String, at url: URL) throws {
        let fileURL = url.appendingPathComponent(name)
        guard let data = image.jpegData(compressionQuality: 1.0) else { throw NSError() }
        try data.write(to: fileURL)
    }

    func removeContent(at url: URL) throws {
        try fileManager.removeItem(at: url)
    }
}
