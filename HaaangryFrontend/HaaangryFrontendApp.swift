//
//  haaangry_frontendApp.swift
//  haaangry-frontend
//
//  Created by xewe on 10/25/25.
//

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
                    await feed.load()
                    await profile.load()
                }
        }
    }
}
