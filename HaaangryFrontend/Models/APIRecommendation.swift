// Models/APIRecommendation.swift
import Foundation

public struct APIMenuItem: Codable, Identifiable, Hashable {
    public let id: String
    public let restaurantId: String
    public let name: String
    public let description: String?
    public let priceCents: Int
    public let imageURL: String?
    public let tags: [String]?

    enum CodingKeys: String, CodingKey {
        case id
        case restaurantId = "restaurant_id"
        case name
        case description
        case priceCents = "price_cents"
        case imageURL = "image_url"
        case tags
    }

    public var displayPrice: String {
        String(format: "$%.2f", Double(priceCents) / 100.0)
    }
}

public struct APIRestaurantBlock: Codable, Identifiable, Hashable {
    public var id: String { restaurantId }

    public let restaurantId: String
    public let restaurantName: String
    public let items: [APIMenuItem]
    public let avgPriceCents: Int
    public let menuLink: String?              // NEW

    enum CodingKeys: String, CodingKey {
        case restaurantId = "restaurant_id"
        case restaurantName = "restaurant_name"
        case items
        case avgPriceCents = "avg_price_cents"
        case menuLink = "menu_url"
    }

    public var displayAvgPrice: String {
        String(format: "$%.2f", Double(avgPriceCents) / 100.0)
    }

    public var menuURL: URL? {
        guard let s = menuLink, let u = URL(string: s) else { return nil }
        return u
    }
}

public struct APIRecommendOut: Codable, Hashable {
    public let recommendations: [APIRestaurantBlock]
}
