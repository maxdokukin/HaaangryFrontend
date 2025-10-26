// Networking/Endpoint.swift
import Foundation

enum Endpoint {
    case feed
    case orderOptions(videoId: String, title: String? = nil)
    case createOrder
    case llmText
    case llmVoice
    case recipes(videoId: String, title: String? = nil, description: String? = nil)
    case profile
    case orderHistory

    var path: String {
        switch self {
        case .feed: return "/feed"
        case .orderOptions: return "/order/options"
        case .createOrder: return "/orders"
        case .llmText: return "/llm/text"
        case .llmVoice: return "/llm/voice"
        case .recipes: return "/recipes"
        case .profile: return "/profile"
        case .orderHistory: return "/orders/history"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .feed, .createOrder, .llmText, .llmVoice, .profile, .orderHistory:
            return nil

        case .orderOptions(let id, let title):
            var items = [URLQueryItem(name: "video_id", value: id)]
            if let t = title, !t.isEmpty { items.append(URLQueryItem(name: "title", value: t)) }
            return items

        case .recipes(let id, let title, let description):
            var items = [URLQueryItem(name: "video_id", value: id)]
            if let t = title, !t.isEmpty { items.append(URLQueryItem(name: "title", value: t)) }
            if let d = description, !d.isEmpty { items.append(URLQueryItem(name: "description", value: d)) }
            return items
        }
    }

    var method: String {
        switch self {
        case .createOrder, .llmText, .llmVoice: return "POST"
        default: return "GET"
        }
    }
}
