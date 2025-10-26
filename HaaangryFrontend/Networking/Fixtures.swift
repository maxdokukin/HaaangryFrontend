import Foundation

enum FixtureFile: String {
    case feed = "feed"
    case orderOptionsV1 = "order_options_v1"
    case recipesV1 = "recipes_v1"
    case recipesLinksV1 = "recipes_links_v1"
    case profile = "profile"
}

struct Fixtures {
    static func load<T: Decodable>(_ file: FixtureFile, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: file.rawValue, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
