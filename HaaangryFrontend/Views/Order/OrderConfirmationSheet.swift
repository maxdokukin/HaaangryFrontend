//
//  OrderConfirmationSheet.swift
//  HaaangryFrontend
//
//  Created by xewe on 10/26/25.
//

import Foundation
// Views/Order/OrderConfirmationSheet.swift
import SwiftUI

struct OrderConfirmationSheet: View {
    let confirmation: OrderConfirmation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)

            Text("Order Confirmed")
                .font(.title3).bold()

            Text(confirmation.id)
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                Text(confirmation.restaurantName)
                    .font(.headline)

                ForEach(confirmation.lines) { line in
                    HStack {
                        Text("\(line.quantity)× \(line.name)")
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        Text(line.lineTotalCents.currencyString)
                            .monospacedDigit()
                    }
                }

                Divider()

                HStack { Text("Subtotal"); Spacer(); Text(confirmation.subtotalCents.currencyString).bold() }
                HStack { Text("Delivery Fee"); Spacer(); Text(confirmation.deliveryFeeCents.currencyString).bold() }
                HStack { Text("Total"); Spacer(); Text(confirmation.totalCents.currencyString).bold() }

                Text("ETA ~\(confirmation.etaMinutes) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .glassContainer(cornerRadius: 14, padding: 12, shadowRadius: 8)

            Button("Done") { dismiss() }
                .glassButtonProminent()
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}
