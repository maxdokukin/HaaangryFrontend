//
//  OrderConfirmation.swift
//  HaaangryFrontend
//
//  Created by xewe on 10/26/25.
//

import Foundation
// Utilities/OrderConfirmation.swift
import Foundation

struct OrderConfirmation: Identifiable, Equatable {
    struct Line: Identifiable, Equatable {
        let id = UUID()
        let name: String
        let quantity: Int
        let lineTotalCents: Int
    }

    let id: String               // order code
    let restaurantName: String
    let lines: [Line]
    let subtotalCents: Int
    let deliveryFeeCents: Int
    let totalCents: Int
    let etaMinutes: Int
}

extension OrderConfirmation {
    static func code() -> String {
        "HAA\(Int.random(in: 1000...9999))"
    }
}

extension Notification.Name {
    static let orderConfirmed = Notification.Name("OrderConfirmed")
}

extension Int {
    var currencyString: String {
        String(format: "$%.2f", Double(self) / 100.0)
    }
}
