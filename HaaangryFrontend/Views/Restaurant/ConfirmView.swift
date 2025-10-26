import SwiftUI

struct ConfirmView: View {
    let restaurantId: String
    let restaurantName: String
    let item: APIMenuItem

    @Environment(\.dismiss) private var dismiss
    @State private var isSubmitting = false
    @State private var statusText: String?
    @State private var errorText: String?

    var body: some View {
        VStack(spacing: 16) {
            header
            summaryCard
            Spacer(minLength: 12)
            submitSection
        }
        .padding()
        .navigationTitle("Confirm")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text(restaurantName)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(item.name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Item")
                Spacer()
                Text(item.name)
                    .multilineTextAlignment(.trailing)
            }
            HStack {
                Text("Price")
                Spacer()
                Text(item.displayPrice)
                    .monospacedDigit()
            }
            if let tags = item.tags, tags.isEmpty == false {
                Divider()
                Text("Tags")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(tags.joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
                Text(statusText)
                    .font(.footnote)
                    .foregroundStyle(.green)
            }
            if let errorText {
                Text(errorText)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            HStack(spacing: 12) {
                Button("Cancel") { dismiss() }
                    .buttonStyle(.bordered)

                Button {
                    Task { await submit() }
                } label: {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text("Place Order (placeholder)")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSubmitting)
            }
        }
    }

    private func submit() async {
        errorText = nil
        statusText = nil
        isSubmitting = true
        defer { isSubmitting = false }

        let resp = await APIClient.shared.confirm(restaurantId: restaurantId, item: item, quantity: 1)
        if let resp, resp.status.lowercased() == "ok" {
            statusText = resp.message ?? "Order acknowledged"
        } else {
            errorText = "Failed to confirm"
        }
    }
}

#if DEBUG
struct ConfirmView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItem = APIMenuItem(
            id: "R1::spaghetti-carbonara",
            restaurantId: "R1",
            name: "Spaghetti Carbonara",
            description: "Classic roman pasta",
            priceCents: 1900,
            imageURL: nil,
            tags: ["pasta","roman"]
        )
        NavigationView {
            ConfirmView(
                restaurantId: "R1",
                restaurantName: "Trattoria Roma",
                item: sampleItem
            )
        }
    }
}
#endif
