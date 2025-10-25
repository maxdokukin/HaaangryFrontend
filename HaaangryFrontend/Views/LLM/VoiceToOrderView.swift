import SwiftUI

struct VoiceToOrderView: View {
    @StateObject var speech = SpeechRecognizer()
    @State private var intent: String?
    @State private var top: [Restaurant] = []
    @State private var isRecording = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Say what you’re craving…").font(.headline)
            Text(speech.transcript.isEmpty ? "…" : speech.transcript)
                .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                .padding().background(Color.gray.opacity(0.15)).cornerRadius(8)

            HStack {
                Button(isRecording ? "Stop" : "Record") {
                    if isRecording {
                        speech.stop()
                        isRecording = false
                    } else {
                        try? speech.start()
                        isRecording = true
                    }
                }
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
            }

            if let intent {
                Text("Detected intent: \(intent)").bold()
                ForEach(top) { r in
                    Text("• \(r.name) (\(r.delivery_eta_min)-\(r.delivery_eta_max) min)")
                }
            }
            Spacer()
        }
        .padding()
    }
}
