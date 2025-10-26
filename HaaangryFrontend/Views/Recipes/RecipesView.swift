// Views/Recipes/RecipesView.swift
// Views/Recipes/RecipesView.swift
import SwiftUI

struct RecipesView: View {
    let video: Video

    @State private var data: RecipeLinksResult?
    @State private var isLoading = false
    @State private var lastLoadedId: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let data {
                let reads = data.links.filter { $0.kind == .read }
                let watches = data.links.filter { $0.kind == .watch }

                Text("Recipe Links").font(.headline)

                if reads.isEmpty == false {
                    Text("READ").bold().padding(.top, 2)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(reads) { link in
                            if let url = URL(string: link.url) {
                                Link(destination: url) {
                                    Label(link.displayTitle, systemImage: "book.fill")
                                        .lineLimit(2)
                                        .truncationMode(.middle)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .glassButton()
                            }
                        }
                    }
                }

                if watches.isEmpty == false {
                    Text("WATCH").bold().padding(.top, 6)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(watches) { link in
                            if let url = URL(string: link.url) {
                                Link(destination: url) {
                                    Label(link.displayTitle, systemImage: "play.rectangle.fill")
                                        .lineLimit(2)
                                        .truncationMode(.middle)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .glassButton()
                            }
                        }
                    }
                }

                if !data.query.isEmpty && data.query != "N/A" {
                    Text("Query: \(data.query)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 6)
                }
            } else {
                VStack(spacing: 8) {
                    Spacer()
                    ProgressView()
                    Text("Looking up recipe articles and video recipes…")
                        .font(.body) // match restaurant suggestions loading font
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
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
            // Use existing fixture filename present in the bundle.
            fallback: .recipesV1
        )
    }
}
