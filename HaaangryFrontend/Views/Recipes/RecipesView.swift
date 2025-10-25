import SwiftUI
import SafariServices

struct RecipesView: View {
    let videoId: String
    @State private var data: RecipeResult?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let data {
                Text("Top Text Recipes").font(.headline)

                List {
                    ForEach(data.top_text_recipes) { r in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(r.title).bold()
                            ForEach(r.steps, id: \.self) { s in Text("• \(s)") }
                        }
                        .glassContainer(cornerRadius: 12, padding: 12, shadowRadius: 6)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.clear)

                Text("Top YouTube").font(.headline).padding(.top, 4)
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(data.top_youtube, id: \.self) { url in
                        Link(destination: URL(string: url)!) {
                            Label(url, systemImage: "play.rectangle")
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .glassButton()
                    }
                }
            } else {
                HStack { Spacer(); ProgressView(); Spacer() }
            }
        }
        .padding()
        .task(id: videoId) {
            data = await APIClient.shared.request(.recipes(videoId: videoId), fallback: .recipesV1)
        }
    }
}
