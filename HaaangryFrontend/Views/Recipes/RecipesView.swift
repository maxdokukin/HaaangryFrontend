import SwiftUI
import SafariServices

struct RecipesView: View {
    let videoId: String
    @State private var data: RecipeResult?

    var body: some View {
        VStack(alignment: .leading) {
            if let data {
                Text("Top Text Recipes").font(.headline)
                List(data.top_text_recipes) { r in
                    VStack(alignment: .leading) {
                        Text(r.title).bold()
                        ForEach(r.steps, id: \.self) { s in Text("• \(s)") }
                    }
                }.listStyle(.plain)

                Text("Top YouTube").font(.headline).padding(.top)
                ForEach(data.top_youtube, id: \.self) { url in
                    Link(destination: URL(string: url)!) {
                        Label(url, systemImage: "play.rectangle")
                    }
                }
            } else {
                ProgressView().task {
                    data = await APIClient.shared.request(.recipes(videoId: videoId), fallback: .recipesV1)
                }
            }
        }.padding()
    }
}
