import Foundation
import UniformTypeIdentifiers

enum LocalOrders {
    private static let fileName = "orders_history.json"

    private static var fileURL: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if #available(iOS 14.0, *) {
            return dir.appendingPathComponent(fileName, conformingTo: UTType.json)
        } else {
            return dir.appendingPathComponent(fileName)
        }
    }

    @MainActor
    static func load() -> [Order] {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Order].self, from: data)
        } catch {
            print("[LocalOrders] load failed:", error.localizedDescription)
            return []
        }
    }

    @MainActor
    static func save(_ orders: [Order]) {
        do {
            let data = try JSONEncoder().encode(orders)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("[LocalOrders] save failed:", error.localizedDescription)
        }
    }

    /// Appends and persists. Returns updated array.
    @discardableResult
    @MainActor
    static func append(_ order: Order) -> [Order] {
        var current = load()
        current.insert(order, at: 0) // newest first
        save(current)
        return current
    }
}
