import SwiftUI

struct ChatToOrderView: View {
    @EnvironmentObject var orders: OrderStore
    @State private var input = ""
    @State private var responseIntent: String?
    @State private var top: [Restaurant] = []

    var body: some View {
        VStack(spacing: 12) {
            ScrollView {
                if let intent = responseIntent {
                    Text("You seem in the mood for: \(intent)")
                        .glassContainer(cornerRadius: 14, padding: 10, shadowRadius: 6)
                        .padding(.bottom, 6)
                    Text("Top picks:").bold()
                    VStack(spacing: 8) {
                        ForEach(top) { r in
                            HStack {
                                Text(r.name).bold()
                                Spacer()
                                Text("\(r.delivery_eta_min)-\(r.delivery_eta_max) min").font(.caption).foregroundStyle(.secondary)
                            }
                            .glassContainer(cornerRadius: 12, padding: 10, shadowRadius: 6)
                        }
                    }
                } else {
                    Text("Feelin haaangry?…")
                        .foregroundStyle(.secondary)
                        .glassContainer(cornerRadius: 12, padding: 10, shadowRadius: 4)
                }
            }

            HStack(spacing: 10) {
                TextField("e.g., spicy ramen with dumplings", text: $input)
                    .glassField()

                Button("Send") {
                    Task {
                        struct Req: Encodable { let user_text: String }
                        struct Resp: Decodable { let intent: String; let top_restaurants: [Restaurant] }
                        if let data: Resp = await APIClient.shared.request(.llmText, body: Req(user_text: input), fallback: nil) {
                            responseIntent = data.intent
                            top = data.top_restaurants
                        }
                    }
                }
                .glassButton()
            }
            .padding(.top, 2)
        }
        .padding()
    }
}
