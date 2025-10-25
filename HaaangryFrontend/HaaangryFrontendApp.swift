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

    init() {
        AudioSession.configurePlayback()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(feed)
                .environmentObject(orders)
                .environmentObject(profile)
                .task {
                    await APIClient.shared.primeServerAvailability()
                    await feed.load()
                    await profile.load()
                }
        }
    }
}
