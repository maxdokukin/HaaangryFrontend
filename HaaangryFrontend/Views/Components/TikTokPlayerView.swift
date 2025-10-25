// Views/Components/TikTokPlayerView.swift
import SwiftUI
import AVFoundation

/// Lightweight, control-less AVPlayerLayer wrapper with looping.
/// Aspect fill. No OS controls. Suited for TikTok-style full-screen playback.
struct TikTokPlayerView: UIViewRepresentable {
    final class PlayerView: UIView {
        override static var layerClass: AnyClass { AVPlayerLayer.self }
        var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    }

    let player: AVPlayer
    var isMuted: Bool

    func makeUIView(context: Context) -> PlayerView {
        let v = PlayerView()
        v.playerLayer.player = player
        v.playerLayer.videoGravity = .resizeAspectFill
        player.isMuted = isMuted
        player.actionAtItemEnd = .none

        context.coordinator.attachLoopObserver(for: player)
        return v
    }

    func updateUIView(_ uiView: PlayerView, context: Context) {
        uiView.playerLayer.player = player
        uiView.playerLayer.videoGravity = .resizeAspectFill
        player.isMuted = isMuted
        context.coordinator.attachLoopObserver(for: player)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // replace the Coordinator.attachLoopObserver with this idempotent version
    final class Coordinator {
        private var token: NSObjectProtocol?

        func attachLoopObserver(for player: AVPlayer) {
            if let token { NotificationCenter.default.removeObserver(token) }
            guard let item = player.currentItem else { return }
            token = NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: item,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }

        deinit { if let token { NotificationCenter.default.removeObserver(token) } }
    }

}
