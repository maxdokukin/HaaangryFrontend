import SwiftUI

struct BottomActionsBar: View {
    @State private var showChat = false
    @State private var showVoice = false
    @State private var showProfile = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                showChat = true
            } label: {
                Label("Chat to Order", systemImage: "message.fill")
                    .padding(.horizontal, 2)
            }
            .glassButton()

            Spacer(minLength: 8)

            Button {
                showVoice = true
            } label: {
                Label("Talk to Order", systemImage: "mic.fill")
                    .padding(.horizontal, 2)
            }
            .glassButton()

            Spacer(minLength: 8)

            Button {
                showProfile = true
            } label: {
                Label("Profile", systemImage: "person.crop.circle")
                    .padding(.horizontal, 2)
            }
            .glassButton()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial) // bar substrate remains translucent
        .sheet(isPresented: $showChat) { ChatToOrderView() }
        .sheet(isPresented: $showVoice) { VoiceToOrderView() }
        .sheet(isPresented: $showProfile) { ProfileView() }
    }
}
