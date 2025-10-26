// Networking/APIClient.swift
import Foundation
import Network

final class APIClient {
    static let shared = APIClient()

    // Read from Info.plist; Simulator defaults to localhost.
    private let baseURL: URL = {
        if let s = Bundle.main.object(forInfoDictionaryKey: "APIBaseURL") as? String,
           let u = URL(string: s) { return u }
        #if targetEnvironment(simulator)
        return URL(string: "http://127.0.0.1:8000")!
        #else
        // On device you must set APIBaseURL in Info.plist
        return URL(string: "http://127.0.0.1:8000")!
        #endif
    }()

    private let session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 5
        c.timeoutIntervalForResource = 10
        c.waitsForConnectivity = false
        return URLSession(configuration: c)
    }()

    private let jsonDecoder = JSONDecoder()
    private var serverAvailable: Bool?

    init() { print("[API] Base URL =", baseURL.absoluteString) }

    func primeServerAvailability() async { /* optional no-op now */ }

    private func makeURL(for endpoint: Endpoint) -> URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = endpoint.path
        if let items = endpoint.queryItems, items.isEmpty == false {
            components?.queryItems = items
        }
        return components?.url
    }

    /// Always try network first. Fallback to fixture on error.
    func request<T: Decodable>(_ endpoint: Endpoint, body: Encodable? = nil, fallback: FixtureFile? = nil) async -> T? {
        do {
            guard let url = makeURL(for: endpoint) else { throw URLError(.badURL) }
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = endpoint.method
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            if let body = body {
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            }

            print("[API] →", urlRequest.httpMethod ?? "GET", url.absoluteString)
            let (data, response) = try await session.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw URLError(.badServerResponse)
            }
            serverAvailable = true
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            serverAvailable = false
            print("[API] Request failed \(endpoint.path):", error.localizedDescription)
            if let fallback = fallback, let v: T = Fixtures.load(fallback, as: T.self) {
                print("[API] Using fixture for", endpoint.path)
                return v
            }
            return nil
        }
    }
}

// Helper to encode arbitrary Encodable
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ encodable: Encodable) {
        self.encodeFunc = { encoder in try encodable.encode(to: encoder) }
    }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}
