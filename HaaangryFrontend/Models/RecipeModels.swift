// Models/RecipeModels.swift
import Foundation

// Models/RecipeModels.swift


struct RecipeLink: Codable, Identifiable, Equatable {
    var id: String { url }
    let title: String
    let url: String

    enum Kind { case read, watch }

    var kind: Kind {
        if let host = URL(string: url)?.host?.lowercased(),
           host.contains("youtube.com") || host.contains("youtu.be") {
            return .watch
        }
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if t.hasPrefix("watch:") { return .watch }
        return .read
    }

    var displayTitle: String {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let lower = t.lowercased()
        if lower.hasPrefix("read:") { return String(t.dropFirst(5)).trimmingCharacters(in: .whitespaces) }
        if lower.hasPrefix("watch:") { return String(t.dropFirst(6)).trimmingCharacters(in: .whitespaces) }
        return t
    }
}

struct RecipeLinksResult: Codable {
    let video_id: String
    let query: String
    let links: [RecipeLink]
}
