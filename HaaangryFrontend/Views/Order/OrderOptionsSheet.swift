// Views/Order/OrderOptionsSheet.swift
import SwiftUI

struct OrderOptionsSheet: View {
    @EnvironmentObject var orders: OrderStore
    @EnvironmentObject var profile: ProfileStore
    @Environment(\.dismiss) private var dismiss
    let video: Video

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let opts = orders.orderOptions, opts.video_id == video.id {
                Text("You’re craving: \(opts.intent)")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 2)

                Text("Top Restaurants").font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(opts.top_restaurants) { r in
                            Button {
                                orders.selectedRestaurant = r
                                orders.recalcTotals()
                            } label: {
                                VStack(spacing: 4) {
                                    Text(r.name).bold()
                                    Text("ETA \(r.delivery_eta_min)-\(r.delivery_eta_max) min")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(minWidth: 140)
                            }
                            .glassButton()
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(
                                        (r.id == orders.selectedRestaurant?.id) ?
                                            Color.accentColor.opacity(0.8) :
                                            Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                    }
                    .padding(.vertical, 6)
                }

                Text("Your Cart").font(.headline)
                ForEach(orders.currentCart) { item in
                    HStack(spacing: 10) {
                        Text(item.name_snapshot)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        HStack(spacing: 8) {
                            Button { orders.dec(item.menu_item_id) } label: { Image(systemName: "minus") }
                                .glassIconButton()
                            Text("\(item.quantity)")
                                .frame(minWidth: 22)
                            Button { orders.inc(item.menu_item_id) } label: { Image(systemName: "plus") }
                                .glassIconButton()
                        }
                        Text(price(item.price_cents_snapshot * item.quantity))
                            .font(.subheadline).bold()
                    }
                    .glassContainer(cornerRadius: 14, padding: 8, shadowRadius: 6)
                }

                if !opts.suggested_items.isEmpty {
                    Text("Suggested").font(.headline).padding(.top, 4)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(opts.suggested_items) { m in
                                Button { orders.addSuggested(m) } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(m.name).bold().lineLimit(1)
                                        Text(price(m.price_cents)).font(.caption)
                                    }
                                    .frame(minWidth: 120, alignment: .leading)
                                }
                                .glassButton()
                            }
                        }
                    }
                }

                Divider().padding(.vertical, 6)

                // Pricing summary with dynamic subtotal and free-delivery switch
                let subtotal = orders.currentCart.reduce(0) { $0 + $1.price_cents_snapshot * $1.quantity }
                let baseFee = orders.selectedRestaurant?.delivery_fee_cents ?? 299

                Toggle("Free delivery", isOn: $orders.freeDelivery)
                    .onChange(of: orders.freeDelivery) { _ in orders.recalcTotals() }

                HStack { Text("Subtotal"); Spacer(); Text(price(subtotal)).bold() }
                HStack {
                    Text("Delivery")
                    Spacer()
                    Text(orders.freeDelivery ? "Free" : price(baseFee)).bold()
                }
                HStack {
                    Text("Total")
                    Spacer()
                    Text(price(orders.totalCents)).bold()
                }

                if let r = orders.selectedRestaurant {
                    Text("ETA: ~\(r.delivery_eta_min)-\(r.delivery_eta_max) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button {
                    Task { await placeOrderAndShowConfirmation() }
                } label: {
                    Text("Place Order")
                        .frame(maxWidth: .infinity)
                }
                .glassButtonProminent()
                .padding(.top, 6)
                .disabled(orders.selectedRestaurant == nil || orders.currentCart.isEmpty)
            } else {
                HStack { Spacer(); ProgressView(); Spacer() }
            }
        }
        .padding()
        .task(id: video.id) {
            await orders.fetchOptions(for: video.id, title: video.title, force: true)
        }
    }

    private func placeOrderAndShowConfirmation() async {
        guard
            let userId = profile.profile?.user_id,
            let r = orders.selectedRestaurant
        else { return }

        // Compute totals for persistence and receipt.
        let subtotal = orders.currentCart.reduce(0) { $0 + $1.price_cents_snapshot * $1.quantity }
        let fee = orders.freeDelivery ? 0 : r.delivery_fee_cents
        let total = subtotal + fee
        let eta = max(r.delivery_eta_min,
                      min(r.delivery_eta_max,
                          orders.etaMinutes > 0 ? orders.etaMinutes
                          : r.delivery_eta_min + (r.delivery_eta_max - r.delivery_eta_min)/2))

        // Try backend; fall back to local id.
        let placed = await orders.placeOrder(userId: userId)
        let orderId = placed?.id ?? OrderConfirmation.code()

        // Persist locally.
        let localOrder = Order(
            id: orderId,
            user_id: userId,
            restaurant_id: r.id,
            status: "confirmed",
            items: orders.currentCart,
            subtotal_cents: subtotal,
            delivery_fee_cents: fee,
            total_cents: total,
            eta_minutes: eta
        )
        profile.appendLocal(localOrder)

        // Build and show receipt.
        let lines = orders.currentCart.map {
            OrderConfirmation.Line(
                name: $0.name_snapshot,
                quantity: $0.quantity,
                lineTotalCents: $0.price_cents_snapshot * $0.quantity
            )
        }
        let receipt = OrderConfirmation(
            id: orderId,
            restaurantName: r.name,
            lines: lines,
            subtotalCents: subtotal,
            deliveryFeeCents: fee,
            totalCents: total,
            etaMinutes: eta
        )

        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            NotificationCenter.default.post(name: .orderConfirmed, object: receipt)
        }
    }

    private func price(_ cents: Int) -> String {
        String(format: "$%.2f", Double(cents)/100.0)
    }
}
