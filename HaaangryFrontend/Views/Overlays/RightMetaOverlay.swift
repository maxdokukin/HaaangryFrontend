import SwiftUI

struct RightMetaOverlay: View {
    let likes: Int
    let comments: Int

    var body: some View {
        VStack(spacing: 14) {
            VStack(spacing: 4) {
                Image(systemName: "heart.fill")
                Text("\(likes)")
            }
            .padding(10)
            .glassContainer(cornerRadius: 12, padding: 6, shadowRadius: 8)

            VStack(spacing: 4) {
                Image(systemName: "text.bubble.fill")
                Text("\(comments)")
            }
            .padding(10)
            .glassContainer(cornerRadius: 12, padding: 6, shadowRadius: 8)
        }
        .font(.caption)
        .padding(.trailing, 6)
    }
}
