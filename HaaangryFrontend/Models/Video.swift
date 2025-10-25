import Foundation

struct Video: Identifiable, Codable, Equatable {
    let id: String
    let url: String
    let thumb_url: String?
    let title: String
    let description: String
    let tags: [String]
    let like_count: Int
    let comment_count: Int
}
