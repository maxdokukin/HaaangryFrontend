import SwiftUI

struct StartupOverlay: View {
    @Binding var isVisible: Bool
    @State private var breathe = false
    @State private var nudgeLeft = false
    @State private var nudgeRight = false

    var body: some View {
        if isVisible {
            ZStack {
                Color.black.ignoresSafeArea()

                // Center slogan
                Text("feelin haaangry?...")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .opacity(breathe ? 1.0 : 0.6)
                    .scaleEffect(breathe ? 1.0 : 0.98)
                    .accessibilityIdentifier("StartupSlogan")

                // Bottom hints
                VStack {
                    Spacer()
                    HStack {
                        // LEFT → Learn more
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left")
                                .offset(x: nudgeLeft ? -6 : 0)
                                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: nudgeLeft)
                            Text("SWIPE LEFT FOR RECIPES")
                        }
                        .hintCapsule()

                        Spacer(minLength: 12)

                        // RIGHT → Order
                        HStack(spacing: 8) {
                            Text("SWIPE RIGHT TO ORDER")
                            Image(systemName: "arrow.right")
                                .offset(x: nudgeRight ? 6 : 0)
                                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: nudgeRight)
                        }
                        .hintCapsule()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
            }
            .contentShape(Rectangle()) // make whole overlay tappable
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.35)) { isVisible = false }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    breathe = true
                }
                nudgeLeft = true
                nudgeRight = true
            }
            .transition(.opacity)
            .zIndex(999)
        }
    }
}

private extension View {
    func hintCapsule() -> some View {
        self
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.10), in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
    }
}
