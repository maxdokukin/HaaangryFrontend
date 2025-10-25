import Foundation

struct Profile: Codable {
    let user_id: String
    let name: String
    let credits_balance_cents: Int
    let default_address: Address
}
struct Address: Codable {
    let line1: String
    let city: String
    let state: String
    let zip: String
}

@MainActor
final class ProfileStore: ObservableObject {
    @Published var profile: Profile?
    @Published var history: [Order] = []

    func load() async {
        self.profile = await APIClient.shared.request(.profile, fallback: .profile)
        // History not strictly needed in MVP, fine to ignore fallback
        if let hist: [String: [Order]] = await APIClient.shared.request(.orderHistory, fallback: nil) {
            self.history = hist["orders"] ?? []
        }
    }
}
