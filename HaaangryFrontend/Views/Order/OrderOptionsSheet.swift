import SwiftUI

struct OrderOptionsSheet: View {
    @EnvironmentObject var orders: OrderStore
    @EnvironmentObject var profile: ProfileStore
    let videoId: String

    var body: some View {
        VStack(alignment: .leading) {
            if let opts = orders.orderOptions {
                Text("You’re craving: \(opts.intent)").font(.title3).padding(.bottom, 8)
                Text("Top Restaurants").font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(opts.top_restaurants) { r in
                            Button {
                                orders.selectedRestaurant = r
                            } label: {
                                VStack {
                                    Text(r.name).bold()
                                    Text("ETA \(r.delivery_eta_min)-\(r.delivery_eta_max) min").font(.caption)
                                }
                                .padding().background(
                                    r.id == orders.selectedRestaurant?.id ? Color.gray.opacity(0.3) : Color.clear
                                ).cornerRadius(8)
                            }
                        }
                    }.padding(.vertical, 6)
                }

                Text("Your Cart").font(.headline)
                ForEach(orders.currentCart) { item in
                    HStack {
                        Text(item.name_snapshot)
                        Spacer()
                        HStack {
                            Button { orders.dec(item.menu_item_id) } label: { Image(systemName: "minus.circle") }
                            Text("\(item.quantity)")
                            Button { orders.inc(item.menu_item_id) } label: { Image(systemName: "plus.circle") }
                        }
                        Text(price(item.price_cents_snapshot * item.quantity))
                    }
                }

                if !opts.suggested_items.isEmpty {
                    Text("Suggested").font(.headline).padding(.top, 6)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(opts.suggested_items) { m in
                                Button {
                                    orders.addSuggested(m)
                                } label: {
                                    VStack(alignment: .leading) {
                                        Text(m.name).bold()
                                        Text(price(m.price_cents))
                                    }
                                    .padding().background(Color.gray.opacity(0.15)).cornerRadius(8)
                                }
                            }
                        }
                    }
                }

                Divider().padding(.vertical, 8)
                HStack {
                    Text("Total")
                    Spacer()
                    Text(price(orders.totalCents)).bold()
                }
                if let r = orders.selectedRestaurant {
                    Text("ETA: ~\(r.delivery_eta_min)-\(r.delivery_eta_max) min").font(.caption)
                }
                Button {
                    Task {
                        if let userId = profile.profile?.user_id {
                            _ = await orders.placeOrder(userId: userId)
                        }
                    }
                } label: {
                    Text("Place Order")
                        .frame(maxWidth: .infinity).padding().background(Color.accentColor).foregroundColor(.white)
                        .cornerRadius(10)
                }.padding(.top, 8)
            } else {
                ProgressView().task { await orders.fetchOptions(for: videoId) }
            }
        }
        .padding()
    }

    private func price(_ cents: Int) -> String {
        String(format: "$%.2f", Double(cents)/100.0)
    }
}
