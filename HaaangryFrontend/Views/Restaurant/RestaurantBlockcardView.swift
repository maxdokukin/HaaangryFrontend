// Views/Restaurant/RestaurantBlockCard.swift
import SwiftUI

struct RestaurantBlockCard: View {
    let block: APIRestaurantBlock
    // Changed: pass both the block and the tapped item
    let onItemTapped: (APIRestaurantBlock, APIMenuItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header                          // clickable when menu_link exists
                .padding()
                .background(Color(.secondarySystemBackground))

            VStack(spacing: 0) {
                ForEach(Array(block.items.enumerated()), id: \.element.id) { idx, item in
                    itemRow(item)
                    if idx < block.items.count - 1 {
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }

    // MARK: - Header

    private var header: some View {
        Group {
            if let url = block.menuURL {
                Link(destination: url) {
                    headerContents
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityLabel(Text("\(block.restaurantName) menu"))
            } else {
                headerContents
            }
        }
    }

    private var headerContents: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(block.restaurantName)
                    .font(.headline)
                Text("Avg \(block.displayAvgPrice)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .font(.caption)
        }
    }

    // MARK: - Item row

    private func itemRow(_ item: APIMenuItem) -> some View {
        Button {
            onItemTapped(block, item)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.body)
                        .foregroundStyle(.primary)

                    if let desc = item.description, !desc.isEmpty {
                        Text(desc)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    if let tags = item.tags, !tags.isEmpty {
                        tagsView(tags)
                    }
                }

                Spacer(minLength: 8)

                Text(item.displayPrice)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func tagsView(_ tags: [String]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags.prefix(4), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

#if DEBUG
struct RestaurantBlockCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                RestaurantBlockCard(
                    block: APIRestaurantBlock(
                        restaurantId: "r1",
                        restaurantName: "Il Fornaio",
                        items: [
                            APIMenuItem(id: "r1::tagliatelle-bolognese", restaurantId: "r1", name: "Tagliatelle Bolognese", description: "Traditional ragù", priceCents: 2400, imageURL: nil, tags: ["italian","pasta"]),
                            APIMenuItem(id: "r1::lasagna", restaurantId: "r1", name: "Lasagna Ferrarese", description: nil, priceCents: 2800, imageURL: nil, tags: ["italian"]),
                            APIMenuItem(id: "r1::gnocchi", restaurantId: "r1", name: "Gnocchi al Pesto", description: "Basil pesto, parmigiano", priceCents: 2700, imageURL: nil, tags: ["vegetarian"])
                        ],
                        avgPriceCents: 2633,
                        menuLink: "https://example.com/menu"
                    ),
                    onItemTapped: { _, _ in }
                )
            }
            .padding()
        }
    }
}
#endif
