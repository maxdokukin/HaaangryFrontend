import SwiftUI

struct VoiceToOrderView: View {
    @StateObject var speech = SpeechRecognizer()
    @State private var intent: String?
    @State private var top: [Restaurant] = []
    @State private var isRecording = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feelin haaangry?…").font(.headline)

            Text(speech.transcript.isEmpty ? "…" : speech.transcript)
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                .glassContainer(cornerRadius: 14, padding: 12, shadowRadius: 6)

            HStack(spacing: 10) {
                Button(isRecording ? "Stop" : "Record") {
                    if isRecording {
                        speech.stop()
                        isRecording = false
                    } else {
                        try? speech.start()
                        isRecording = true
                    }
                }
                .glassButton()

                Button("Analyze") {
                    Task {
                        struct Req: Encodable { let transcript: String }
                        struct Resp: Decodable { let intent: String; let top_restaurants: [Restaurant] }
                        if let data: Resp = await APIClient.shared.request(.llmVoice, body: Req(transcript: speech.transcript), fallback: nil) {
                            intent = data.intent
                            top = data.top_restaurants
                        }
                    }
                }
                .glassButton()
            }

            if let intent {
                Text("Detected intent: \(intent)").bold()
                    .glassContainer(cornerRadius: 12, padding: 10, shadowRadius: 6)
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
            }
            Spacer(minLength: 0)
        }
        .padding()
    }
}
