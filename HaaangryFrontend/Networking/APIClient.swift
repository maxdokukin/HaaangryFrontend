// Networking/APIClient.swift
import Foundation
import Network

final class APIClient {
    static let shared = APIClient()

    // Change baseURL to your FastAPI host if needed
    private let baseURL = URL(string: "http://127.0.0.1:8000")!

    private let session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 3
        c.timeoutIntervalForResource = 5
        c.waitsForConnectivity = false
        return URLSession(configuration: c)
    }()

    private let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    // Server availability cache
    private let probeQueue = DispatchQueue(label: "APIClient.Probe")
    private var serverAvailable: Bool?

    var isServerLikelyAvailable: Bool {
        serverAvailable ?? true
    }

    func primeServerAvailability() async {
        _ = await checkServerAvailability()
    }

    func request<T: Decodable>(_ endpoint: Endpoint, body: Encodable? = nil, fallback: FixtureFile? = nil) async -> T? {
        // If we have fixtures and server is known down, skip the network to avoid OS log spam
        if let fallback = fallback, await checkServerAvailability() == false {
            return Fixtures.load(fallback, as: T.self)
        }

        do {
            var urlRequest = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
            urlRequest.httpMethod = endpoint.method
            urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
            if let body = body {
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            }

            let (data, response) = try await session.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                throw URLError(.badServerResponse)
            }
            serverAvailable = true
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            // Mark down so subsequent calls with fixtures skip the network
            serverAvailable = false
            if let fallback = fallback {
                return Fixtures.load(fallback, as: T.self)
            }
            return nil
        }
    }

    // MARK: - Local server probe (fast, avoids connection-refused noise)

    private func checkServerAvailability() async -> Bool {
        if let cached = serverAvailable { return cached }

        let host = baseURL.host ?? "127.0.0.1"
        let portValue = baseURL.port ?? (baseURL.scheme == "https" ? 443 : 80)
        guard let nwPort = NWEndpoint.Port(rawValue: UInt16(portValue)) else {
            serverAvailable = true
            return true
        }

        return await withCheckedContinuation { cont in
            let conn = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .tcp)
            var resumed = false

            func finish(_ ok: Bool) {
                if !resumed {
                    resumed = true
                    conn.cancel()
                    serverAvailable = ok
                    cont.resume(returning: ok)
                }
            }

            conn.stateUpdateHandler = { state in
                switch state {
                case .ready: finish(true)
                case .failed, .cancelled: finish(false)
                default: break
                }
            }

            conn.start(queue: probeQueue)
            probeQueue.asyncAfter(deadline: .now() + 0.25) { finish(false) }
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
