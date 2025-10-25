import Foundation

enum Endpoint {
    case feed
    case orderOptions(videoId: String)
    case createOrder
    case llmText
    case llmVoice
    case recipes(videoId: String)
    case profile
    case orderHistory

    var path: String {
        switch self {
        case .feed: return "/feed"
        case .orderOptions(let id): return "/order/options?video_id=\(id)"
        case .createOrder: return "/orders"
        case .llmText: return "/llm/text"
        case .llmVoice: return "/llm/voice"
        case .recipes(let id): return "/recipes?video_id=\(id)"
        case .profile: return "/profile"
        case .orderHistory: return "/orders/history"
        }
    }

    var method: String {
        switch self {
        case .createOrder, .llmText, .llmVoice: return "POST"
        default: return "GET"
        }
    }
}
