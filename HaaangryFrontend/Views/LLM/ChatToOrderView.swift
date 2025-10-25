import SwiftUI

struct ChatToOrderView: View {
    @EnvironmentObject var orders: OrderStore
    @State private var input = ""
    @State private var responseIntent: String?
    @State private var top: [Restaurant] = []

    var body: some View {
        VStack {
            ScrollView {
                if let intent = responseIntent {
                    Text("You seem in the mood for: \(intent)").padding(.bottom)
                    Text("Top picks:").bold()
                    ForEach(top) { r in
                        Text("• \(r.name) (\(r.delivery_eta_min)-\(r.delivery_eta_max) min)")
                    }
                } else {
                    Text("Tell me what you feel like eating…").foregroundStyle(.secondary)
                }
            }
            HStack {
                TextField("e.g., spicy ramen with dumplings", text: $input)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
            }.padding(.top)
        }
        .padding()
    }
}
