import Foundation

struct MenuItem: Identifiable, Codable, Equatable {
    let id: String
    let restaurant_id: String
    let name: String
    let description: String?
    let price_cents: Int
    let image_url: String?
    let tags: [String]?
}
