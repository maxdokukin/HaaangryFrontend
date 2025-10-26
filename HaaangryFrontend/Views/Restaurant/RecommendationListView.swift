import SwiftUI

struct RecommendationListView: View {
    let video: Video

    @State private var recommendations: [APIRestaurantBlock] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selection: SelectedItem?

    var body: some View {
        Group {
            if isLoading {
                VStack { Spacer(); ProgressView("Finding restaurants…"); Spacer() }
            } else if let errorMessage {
                errorView(errorMessage)
            } else {
                contentView
            }
        }
        .navigationTitle("Recommendations")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: video.id) { await loadRecommendations() }
        .sheet(item: $selection) { s in
            NavigationStack {
                ConfirmView(
                    restaurantId: s.restaurantId,
                    restaurantName: s.restaurantName,
                    item: s.item
                )
            }
        }
    }

    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(recommendations) { block in
                    RestaurantBlockCard(block: block) { item in
                        selection = SelectedItem(
                            restaurantId: block.restaurantId,
                            restaurantName: block.restaurantName,
                            item: item
                        )
                    }
                }
            }
            .padding()
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 42))
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Retry") { Task { await loadRecommendations() } }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func loadRecommendations() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let res = await APIClient.shared.recommend(videoID: video.id)
        if let recs = res?.recommendations {
            recommendations = recs
            if recs.isEmpty { errorMessage = "No recommendations found." }
        } else {
            errorMessage = "Failed to load recommendations."
        }
    }
}

private struct SelectedItem: Identifiable {
    let id = UUID()
    let restaurantId: String
    let restaurantName: String
    let item: APIMenuItem
}

#if DEBUG
struct RecommendationListView_Previews: PreviewProvider {
    static var previews: some View {
        let v = Video(
            id: "demo",
            url: "https://example.com",
            thumb_url: nil,
            title: "Rome-Style Carbonara",
            description: "Guanciale, eggs, pecorino",
            tags: ["pasta","roman"],
            like_count: 123,
            comment_count: 45
        )
        NavigationStack {
            RecommendationListView(video: v)
        }
    }
}
#endif
