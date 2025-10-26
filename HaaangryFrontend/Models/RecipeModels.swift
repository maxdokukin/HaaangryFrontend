import Foundation

struct RecipeLink: Codable, Identifiable, Equatable {
    var id: String { url }
    let title: String
    let url: String
}

struct RecipeLinksResult: Codable {
    let video_id: String
    let query: String
    let links: [RecipeLink]
}
