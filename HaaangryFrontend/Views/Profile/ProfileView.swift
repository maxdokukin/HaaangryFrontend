import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profile: ProfileStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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

            Text("Order History").font(.headline)
            if profile.history.isEmpty {
                Text("No orders yet.")
                    .foregroundStyle(.secondary)
                    .glassContainer(cornerRadius: 12, padding: 10, shadowRadius: 6)
            }
            Spacer()
        }
        .padding()
    }
}
