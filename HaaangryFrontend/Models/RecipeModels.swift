import Foundation

struct TextRecipe: Codable, Identifiable, Equatable {
    var id: String { title }
    let title: String
    let steps: [String]
}

struct RecipeResult: Codable {
    let video_id: String
    let top_text_recipes: [TextRecipe]
    let top_youtube: [String]
}
