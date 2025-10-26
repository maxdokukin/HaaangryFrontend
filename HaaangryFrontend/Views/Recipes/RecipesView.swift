import SwiftUI

struct RecipesView: View {
    let video: Video

    @State private var data: RecipeLinksResult?
    @State private var isLoading = false
    @State private var lastLoadedId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let data {
                Text("Top Recipe Links").font(.headline)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(data.links) { link in
                        Link(destination: URL(string: link.url)!) {
                            Label(link.title, systemImage: "link")
                                .lineLimit(2)
                                .truncationMode(.middle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .glassButton()
                    }
                }

                if !data.query.isEmpty && data.query != "N/A" {
                    Text("Query: \(data.query)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                }
            } else {
                HStack { Spacer(); ProgressView(); Spacer() }
            }
        }
        .padding()
        .onAppear { Task { await loadIfNeeded() } }
        .onChange(of: video.id) { _ in Task { await load(force: true) } }
    }

    // MARK: - Loading

    private func loadIfNeeded() async {
        await load(force: lastLoadedId != video.id || data == nil)
    }

    private func load(force: Bool) async {
        guard force else { return }
        isLoading = true
        defer { isLoading = false }
        lastLoadedId = video.id
        print("[Recipes] → GET /recipes?video_id=\(video.id)")
        data = await APIClient.shared.request(
            .recipes(videoId: video.id, title: video.title, description: video.description),
            fallback: .recipesLinksV1
        )
    }
}
