import SwiftUI

struct ConfirmView: View {
    let restaurantId: String
    let restaurantName: String
    let items: [APIMenuItem]
    let preselectedItemId: String?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var profile: ProfileStore

    @State private var isSubmitting = false
    @State private var errorText: String?
    @State private var statusText: String?

    @State private var quantities: [String: Int] = [:]
    @State private var freeDelivery: Bool = true // default to free as requested

    private let maxQty = 9
    private let fallbackDeliveryFee = 299

    var body: some View {
        VStack(spacing: 16) {
            header

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(items) { it in
                        itemRow(it)
                    }
                }
            }

            summaryCard

            submitSection
        }
        .padding()
        .navigationTitle("Confirm")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: seedQuantitiesIfNeeded)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text(restaurantName)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Select any of the offered items")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func itemRow(_ item: APIMenuItem) -> some View {
        let qty = quantities[item.id, default: 0]
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).font(.body)
                if let d = item.description, !d.isEmpty {
                    Text(d).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
                if let tags = item.tags, !tags.isEmpty {
                    Text(tags.prefix(4).joined(separator: ", "))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                Stepper(value: Binding(
                    get: { quantities[item.id, default: 0] },
                    set: { quantities[item.id] = max(0, min(maxQty, $0)) }
                ), in: 0...maxQty) {
                    Text("Qty: \(qty)")
                }
                .labelsHidden()

                Text(price(item.priceCents * qty))
                    .monospacedDigit()
                    .font(.callout.weight(.semibold))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var summaryCard: some View {
        let subtotal = selectedLines().reduce(0) { $0 + $1.lineTotalCents }
        let fee = freeDelivery ? 0 : fallbackDeliveryFee
        let total = subtotal + fee

        return VStack(alignment: .leading, spacing: 8) {
            Toggle("Free delivery", isOn: $freeDelivery)

            HStack { Text("Subtotal"); Spacer(); Text(price(subtotal)).bold() }
            HStack { Text("Delivery"); Spacer(); Text(freeDelivery ? "Free" : price(fee)).bold() }
            HStack { Text("Total"); Spacer(); Text(price(total)).bold() }

            Text("ETA ~30 min")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var submitSection: some View {
        VStack(spacing: 10) {
            if let statusText {
                Text(statusText).font(.footnote).foregroundStyle(.green)
            }
            if let errorText {
                Text(errorText).font(.footnote).foregroundStyle(.red)
            }
            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)

                Button {
                    Task { await submit() }
                } label: {
                    if isSubmitting {
                        ProgressView().progressViewStyle(.circular)
                    } else {
                        Text("Place Order")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSubmitting || selectedLines().isEmpty)
            }
        }
    }

    private func selectedLines() -> [OrderConfirmation.Line] {
        items.compactMap { it in
            let q = quantities[it.id, default: 0]
            guard q > 0 else { return nil }
            return OrderConfirmation.Line(
                name: it.name,
                quantity: q,
                lineTotalCents: it.priceCents * q
            )
        }
    }

    private func submit() async {
        errorText = nil
        statusText = nil
        isSubmitting = true
        defer { isSubmitting = false }

        // Optional best-effort confirm for the first line; pure front end otherwise.
        if let first = items.first(where: { quantities[$0.id, default: 0] > 0 }) {
            _ = await APIClient.shared.confirm(restaurantId: restaurantId, item: first, quantity: quantities[first.id, default: 1])
        }

        let lines = selectedLines()
        let subtotal = lines.reduce(0) { $0 + $1.lineTotalCents }
        let fee = freeDelivery ? 0 : fallbackDeliveryFee
        let total = subtotal + fee

        // Persist locally as structured Order.
        if let uid = profile.profile?.user_id {
            let selectedItems: [OrderItem] = items.compactMap { it in
                let q = quantities[it.id, default: 0]
                guard q > 0 else { return nil }
                return OrderItem(
                    menu_item_id: it.id,
                    name_snapshot: it.name,
                    price_cents_snapshot: it.priceCents,
                    quantity: q
                )
            }
            let order = Order(
                id: OrderConfirmation.code(),
                user_id: uid,
                restaurant_id: restaurantId,
                status: "confirmed",
                items: selectedItems,
                subtotal_cents: subtotal,
                delivery_fee_cents: fee,
                total_cents: total,
                eta_minutes: 30
            )
            profile.appendLocal(order)
        }

        let receipt = OrderConfirmation(
            id: OrderConfirmation.code(),
            restaurantName: restaurantName,
            lines: lines,
            subtotalCents: subtotal,
            deliveryFeeCents: fee,
            totalCents: total,
            etaMinutes: 30
        )

        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            NotificationCenter.default.post(name: .orderConfirmed, object: receipt)
        }
    }

    private func seedQuantitiesIfNeeded() {
        if quantities.isEmpty {
            var q: [String: Int] = [:]
            items.forEach { q[$0.id] = 0 }
            if let pid = preselectedItemId, q.keys.contains(pid) {
                q[pid] = 1
            } else if let first = items.first {
                q[first.id] = 1
            }
            quantities = q
        }
    }

    private func price(_ cents: Int) -> String {
        String(format: "$%.2f", Double(cents)/100.0)
    }
}

#if DEBUG
struct ConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItems = [
            APIMenuItem(id: "R1::spaghetti", restaurantId: "R1", name: "Spaghetti Carbonara", description: "Classic roman pasta", priceCents: 1900, imageURL: nil, tags: ["pasta","roman"]),
            APIMenuItem(id: "R1::amatriciana", restaurantId: "R1", name: "Bucatini all’Amatriciana", description: "Tomato, guanciale", priceCents: 1800, imageURL: nil, tags: ["pasta"]),
            APIMenuItem(id: "R1::cacio", restaurantId: "R1", name: "Cacio e Pepe", description: "Pecorino, pepper", priceCents: 1700, imageURL: nil, tags: ["pasta"])
        ]
        NavigationView {
            ConfirmView(
                restaurantId: "R1",
                restaurantName: "Trattoria Roma",
                items: sampleItems,
                preselectedItemId: sampleItems[0].id
            )
            .environmentObject(ProfileStore())
        }
    }
}
#endif
