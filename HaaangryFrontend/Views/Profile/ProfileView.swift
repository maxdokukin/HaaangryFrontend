import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profile: ProfileStore
    @State private var selectedConfirmation: OrderConfirmation?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            Text("Order History").font(.headline)

            if profile.history.isEmpty {
                Text("No orders yet.")
                    .foregroundStyle(.secondary)
                    .glassContainer(cornerRadius: 12, padding: 10, shadowRadius: 6)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(profile.history) { o in
                            Button {
                                selectedConfirmation = mapToConfirmation(o)
                            } label: {
                                HStack(alignment: .firstTextBaseline) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(orderTitle(o))
                                            .font(.subheadline).bold()
                                        Text(o.status.capitalized)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(o.total_cents.currencyString)
                                        .font(.subheadline).bold()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .glassContainer(cornerRadius: 12, padding: 12, shadowRadius: 6)
                        }
                    }
                    .padding(.top, 2)
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .sheet(item: $selectedConfirmation) { c in
            OrderConfirmationSheet(confirmation: c)
        }
    }

    // MARK: - Header

    private var header: some View {
        Group {
            if let p = profile.profile {
                VStack(alignment: .leading, spacing: 6) {
                    Text(p.name).font(.title).bold()
                    Text("\(p.default_address.line1), \(p.default_address.city), \(p.default_address.state) \(p.default_address.zip)")
                        .foregroundStyle(.secondary)
                    Text("Credits: $\(String(format:"%.2f", Double(p.credits_balance_cents)/100))")
                        .bold()
                }
                .glassContainer(cornerRadius: 16, padding: 14, shadowRadius: 10)
            } else {
                HStack { Spacer(); ProgressView(); Spacer() }
            }
        }
    }

    // MARK: - Helpers

    private func orderTitle(_ o: Order) -> String {
        let short = o.id.isEmpty ? "—" : String(o.id.prefix(8))
        return "Order \(short) • R:\(o.restaurant_id)"
    }

    private func mapToConfirmation(_ o: Order) -> OrderConfirmation {
        let lines = o.items.map { it in
            OrderConfirmation.Line(
                name: it.name_snapshot,
                quantity: it.quantity,
                lineTotalCents: it.price_cents_snapshot * it.quantity
            )
        }
        return OrderConfirmation(
            id: o.id.isEmpty ? OrderConfirmation.code() : o.id,
            restaurantName: "Restaurant \(o.restaurant_id)",
            lines: lines,
            subtotalCents: o.subtotal_cents,
            deliveryFeeCents: o.delivery_fee_cents,
            totalCents: o.total_cents,
            etaMinutes: max(10, o.eta_minutes == 0 ? 30 : o.eta_minutes)
        )
    }
}
