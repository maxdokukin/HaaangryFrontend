import Foundation

struct OrderItem: Codable, Identifiable, Equatable {
    var id: String { menu_item_id + "-" + name_snapshot }
    let menu_item_id: String
    let name_snapshot: String
    let price_cents_snapshot: Int
    var quantity: Int
}

struct Order: Codable, Identifiable, Equatable {
    let id: String
    let user_id: String
    let restaurant_id: String
    var status: String
    var items: [OrderItem]
    var subtotal_cents: Int
    var delivery_fee_cents: Int
    var total_cents: Int
    var eta_minutes: Int
}

struct OrderOptions: Codable {
    let video_id: String
    let intent: String
    let top_restaurants: [Restaurant]
    let prefill: [OrderItem]
    let suggested_items: [MenuItem]
}
