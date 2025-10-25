import Foundation

struct Restaurant: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let logo_url: String?
    let delivery_eta_min: Int
    let delivery_eta_max: Int
    let delivery_fee_cents: Int
}
