import Foundation
import AVFoundation
import Combine

@MainActor
final class PlayerPool: ObservableObject {
    @Published private(set) var players: [String: AVPlayer] = [:]

    func player(for id: String, url: URL, muted: Bool) -> AVPlayer {
        if let p = players[id] { p.isMuted = muted; return p }
        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.actionAtItemEnd = .none
        p.automaticallyWaitsToMinimizeStalling = false
        p.allowsExternalPlayback = false
        p.isMuted = muted
        players[id] = p
        return p
    }

    func warm(id: String, url: URL) { _ = player(for: id, url: url, muted: true) }

    /// Play without touching mute state if the player already exists.
    func playKeepingMuteState(id: String, url: URL, defaultMuted: Bool) {
        if let p = players[id] {
            p.play()
        } else {
            let p = player(for: id, url: url, muted: defaultMuted)
            p.play()
        }
    }

    func pauseAll() { players.values.forEach { $0.pause() } }

    func pauseAll(except ids: Set<String>) {
        for (k, v) in players where !ids.contains(k) { v.pause() }
    }

    func trim(keep ids: Set<String>) {
        for key in players.keys where !ids.contains(key) {
            players[key]?.pause()
            players.removeValue(forKey: key)
        }
    }
}
