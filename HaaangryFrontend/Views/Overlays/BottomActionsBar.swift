import SwiftUI

struct BottomActionsBar: View {
    @State private var showChat = false
    @State private var showVoice = false
    @State private var showProfile = false

    var body: some View {
        HStack(spacing: 10) {
            Button {
                showChat = true
            } label: {
                Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                    .labelStyle(.titleAndIcon)
                    .imageScale(.medium)
            }
            .frame(maxWidth: .infinity)
            .glassButton(width: nil, height: 46)

            Button {
                showVoice = true
            } label: {
                Label("Talk", systemImage: "mic.fill")
                    .labelStyle(.titleAndIcon)
                    .imageScale(.medium)
            }
            .frame(maxWidth: .infinity)
            .glassButton(width: nil, height: 46)

            Button {
                showProfile = true
            } label: {
                Label("Profile", systemImage: "person.crop.circle")
                    .labelStyle(.titleAndIcon)
                    .imageScale(.medium)
            }
            .frame(maxWidth: .infinity)
            .glassButton(width: nil, height: 46)
        }
        .glassContainer(cornerRadius: 24, padding: 8, shadowRadius: 14)
        .sheet(isPresented: $showChat) { ChatToOrderView() }
        .sheet(isPresented: $showVoice) { VoiceToOrderView() }
        .sheet(isPresented: $showProfile) { ProfileView() }
    }
}
