import SwiftUI

struct RightMetaOverlay: View {
    let likes: Int
    let comments: Int

    var body: some View {
        VStack(spacing: 12) {
            stat(icon: "heart.fill", value: likes)
            stat(icon: "text.bubble.fill", value: comments)
        }
        .padding(.trailing, 6)
    }

    private func stat(icon: String, value: Int) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.headline)
            Text(value.formatted(.number.notation(.compactName)))
                .font(.caption2)
                .monospacedDigit()
        }
        .frame(width: 66, height: 66)
        .glassContainer(cornerRadius: 14, padding: 8, shadowRadius: 10)
    }
}
