import UIKit
import Foundation

protocol FileManagerServiceProtocol {
    func contentsOfDirectory(at url: URL) -> [Content]
    func createDirectory(named name: String, at url: URL) throws
    func createFile(with image: UIImage, named name: String, at url: URL) throws
    func removeContent(at url: URL) throws
}
