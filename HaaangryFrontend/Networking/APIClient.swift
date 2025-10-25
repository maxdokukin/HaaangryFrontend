import Foundation

final class APIClient {
    static let shared = APIClient()
    // Change baseURL to your FastAPI host if needed
    private let baseURL = URL(string: "http://127.0.0.1:8000")!

    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    func request<T: Decodable>(_ endpoint: Endpoint, body: Encodable? = nil, fallback: FixtureFile? = nil) async -> T? {
        do {
            var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
            urlRequest.httpMethod = endpoint.method
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            if let body = body {
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            }

            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw URLError(.badServerResponse)
            }
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            if let fallback = fallback {
                return Fixtures.load(fallback, as: T.self)
            }
            return nil
        }
    }
}

// Helper to encode arbitrary Encodable
struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ encodable: Encodable) {
        self.encodeFunc = encodable.encode
    }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}
