import SwiftUI

struct RightMetaOverlay: View {
    let likes: Int
    let comments: Int

    var body: some View {
        VStack(spacing: 12) {
            stat(icon: "heart.fill", value: likes)
            stat(icon: "text.bubble.fill", value: comments)
        }
        .padding(.vertical, 8)
    }

    private func stat(icon: String, value: Int) -> some View {
        let shape = Circle()
        return VStack(spacing: 3) {
            Image(systemName: icon)
                .font(.headline)
            Text(value.formatted(.number.notation(.compactName)))
                .font(.caption2)
                .monospacedDigit()
        }
        .frame(width: 60, height: 60)
        .background(.ultraThinMaterial, in: shape)
        .overlay(Glass.gloss(shape).allowsHitTesting(false))
        .overlay(Glass.stroke(shape))
        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 7)
        .contentShape(shape)
    }
}
