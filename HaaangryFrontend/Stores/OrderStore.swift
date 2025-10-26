// Stores/OrderStore.swift
import Foundation
import Combine

@MainActor
final class OrderStore: ObservableObject {
    @Published var orderOptions: OrderOptions?
    @Published var currentCart: [OrderItem] = []
    @Published var selectedRestaurant: Restaurant?
    @Published var etaMinutes: Int = 0
    @Published var totalCents: Int = 0
    @Published var freeDelivery: Bool = false   // NEW

    /// Always safe to call. Clears stale state when video changes.
    func fetchOptions(for videoId: String, title: String? = nil, force: Bool = false) async {
        if force || orderOptions?.video_id != videoId {
            // Reset UI while loading new video’s options
            self.orderOptions = nil
            self.currentCart = []
            self.selectedRestaurant = nil
            self.etaMinutes = 0
            self.totalCents = 0
            self.freeDelivery = false
        }

        if let opts: OrderOptions = await APIClient.shared.request(.orderOptions(videoId: videoId, title: title), fallback: .orderOptionsV1) {
            self.orderOptions = opts
            self.currentCart = opts.prefill
            self.selectedRestaurant = opts.top_restaurants.first
            recalcTotals()
        }
    }

    func addSuggested(_ item: MenuItem) {
        let order = OrderItem(menu_item_id: item.id, name_snapshot: item.name, price_cents_snapshot: item.price_cents, quantity: 1)
        currentCart.append(order)
        recalcTotals()
    }

    func inc(_ id: String) {
        if let idx = currentCart.firstIndex(where: { $0.menu_item_id == id }) {
            currentCart[idx].quantity += 1
            recalcTotals()
        }
    }

    func dec(_ id: String) {
        if let idx = currentCart.firstIndex(where: { $0.menu_item_id == id }) {
            currentCart[idx].quantity = max(0, currentCart[idx].quantity - 1)
            recalcTotals()
        }
        currentCart.removeAll { $0.quantity == 0 }
    }

    func recalcTotals() {
        let subtotal = currentCart.reduce(0) { $0 + $1.price_cents_snapshot * $1.quantity }
        let baseFee = selectedRestaurant?.delivery_fee_cents ?? 299
        let fee = freeDelivery ? 0 : baseFee
        totalCents = subtotal + fee
        etaMinutes = 30
    }

    func placeOrder(userId: String) async -> Order? {
        guard let restaurant = selectedRestaurant else { return nil }
        let subtotal = currentCart.reduce(0) { $0 + $1.price_cents_snapshot * $1.quantity }
        let fee = freeDelivery ? 0 : restaurant.delivery_fee_cents
        let body = Order(
            id: "temp", user_id: userId, restaurant_id: restaurant.id,
            status: "created", items: currentCart,
            subtotal_cents: subtotal, delivery_fee_cents: fee,
            total_cents: subtotal + fee, eta_minutes: 0
        )
        let placed: Order? = await APIClient.shared.request(.createOrder, body: body, fallback: nil)
        return placed
    }
}
