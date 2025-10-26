import SwiftUI

struct RootView: View {
    @State private var showStartupOverlay = true

    var body: some View {
        ZStack {
            VideoFeedView()
                .preferredColorScheme(.dark)

            StartupOverlay(isVisible: $showStartupOverlay)
        }
        .onAppear {
            // Keep the overlay for ~3 seconds, then fade it out.
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.35)) {
                    showStartupOverlay = false
                }
            }
        }
    }
}
