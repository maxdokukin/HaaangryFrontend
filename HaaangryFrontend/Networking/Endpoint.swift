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

    private static func enc(_ s: String) -> String {
        let disallowed = CharacterSet(charactersIn: "&+=?/#")
        let allowed = CharacterSet.urlQueryAllowed.subtracting(disallowed)
        return s.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }

    var path: String {
        switch self {
        case .feed:
            return "/feed"

        case .orderOptions(let id, let title):
            if let t = title, !t.isEmpty {
                return "/order/options?video_id=\(id)&title=\(Endpoint.enc(t))"
            } else {
                return "/order/options?video_id=\(id)"
            }

        case .createOrder:
            return "/orders"

        case .llmText:
            return "/llm/text"

        case .llmVoice:
            return "/llm/voice"

        case .recipes(let id, let title, let description):
            var p = "/recipes?video_id=\(id)"
            if let t = title, !t.isEmpty { p += "&title=\(Endpoint.enc(t))" }
            if let d = description, !d.isEmpty { p += "&description=\(Endpoint.enc(d))" }
            return p

        case .profile:
            return "/profile"

        case .orderHistory:
            return "/orders/history"
        }
    }

    var method: String {
        switch self {
        case .createOrder, .llmText, .llmVoice: return "POST"
        default: return "GET"
        }
    }
}
