import Foundation
import Combine

@MainActor
final class FeedStore: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false

    func load() async {
        isLoading = true
        defer { isLoading = false }
        if let items: [Video] = await APIClient.shared.request(.feed, fallback: .feed) {
            self.videos = items
        }
    }
}
