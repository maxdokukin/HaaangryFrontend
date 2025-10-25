// Utilities/PlayerPool.swift
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
        p.isMuted = muted
        players[id] = p
        return p
    }

    func warm(id: String, url: URL) {
        _ = player(for: id, url: url, muted: true)
    }

    func trim(keep ids: Set<String>) {
        for key in players.keys where !ids.contains(key) {
            players[key]?.pause()
            players.removeValue(forKey: key)
        }
    }

    func pauseAll() { players.values.forEach { $0.pause() } }
}
