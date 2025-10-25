import SwiftUI

struct BottomActionsBar: View {
    @State private var showChat = false
    @State private var showVoice = false
    @State private var showProfile = false

    var body: some View {
        HStack {
            Button {
                showChat = true
            } label: {
                Label("Chat to Order", systemImage: "message.fill")
            }
            Spacer()
            Button {
                showVoice = true
            } label: {
                Label("Talk to Order", systemImage: "mic.fill")
            }
            Spacer()
            Button {
                showProfile = true
            } label: {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .sheet(isPresented: $showChat) { ChatToOrderView() }
        .sheet(isPresented: $showVoice) { VoiceToOrderView() }
        .sheet(isPresented: $showProfile) { ProfileView() }
    }
}
