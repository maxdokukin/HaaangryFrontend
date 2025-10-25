import SwiftUI

struct RightMetaOverlay: View {
    let likes: Int
    let comments: Int

    var body: some View {
        VStack(spacing: 18) {
            VStack {
                Image(systemName: "heart.fill")
                Text("\(likes)")
            }
            VStack {
                Image(systemName: "text.bubble.fill")
                Text("\(comments)")
            }
        }
        .font(.caption)
        .padding(.trailing, 4)
    }
}
