// HaaangryFrontendApp.swift
//
//  HaaangryFrontendApp.swift
//  haaangry-frontend
//

import SwiftUI

@main
struct HaaangryFrontendApp: App {
    @StateObject var feed = FeedStore()
    @StateObject var orders = OrderStore()
    @StateObject var profile = ProfileStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(feed)
                .environmentObject(orders)
                .environmentObject(profile)
                .task {
                    // Probe once so requests with fixtures can bypass network if server is down
                    await APIClient.shared.primeServerAvailability()
                    await feed.load()
                    await profile.load()
                }
        }
    }
}
