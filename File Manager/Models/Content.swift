import Foundation

struct Content {
    let name: String
    let url: URL
    let type: ContentType
}

enum ContentType {
    case file
    case folder
}
