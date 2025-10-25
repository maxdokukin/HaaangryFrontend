import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profile: ProfileStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let p = profile.profile {
                Text(p.name).font(.title)
                Text("\(p.default_address.line1), \(p.default_address.city), \(p.default_address.state) \(p.default_address.zip)")
                    .foregroundStyle(.secondary)
                Text("Credits: $\(String(format:"%.2f", Double(p.credits_balance_cents)/100))").bold()
            } else {
                ProgressView()
            }
            Divider().padding(.vertical, 8)
            Text("Order History").font(.headline)
            if profile.history.isEmpty {
                Text("No orders yet.")
            }
            Spacer()
        }
        .padding()
    }
}
