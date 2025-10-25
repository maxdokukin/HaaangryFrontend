import SwiftUI
import AVFoundation

private enum SheetRoute: Identifiable {
    case order(Video)
    case recipes(Video)

    var id: String {
        switch self {
        case .order(let v):   return "order-\(v.id)"
        case .recipes(let v): return "recipes-\(v.id)"
        }
    }
}

struct VideoFeedView: View {
    @EnvironmentObject var feed: FeedStore
    @EnvironmentObject var orders: OrderStore

    @State private var currentIndex: Int = 0
    @State private var sheet: SheetRoute?

    @StateObject private var pool = PlayerPool()

    var body: some View {
        ZStack {
            if feed.videos.isEmpty {
                ProgressView().task { await feed.load() }
            } else {
                VerticalPager(
                    count: feed.videos.count,
                    index: $currentIndex,
                    onSwipeLeft: { i in sheet = .recipes(feed.videos[i]) },
                    onSwipeRight: { i in sheet = .order(feed.videos[i]) }
                ) { i in
                    VideoCardView(
                        video: feed.videos[i],
                        isActive: i == currentIndex
                    )
                    .environmentObject(pool)
                    .ignoresSafeArea()
                }
                .ignoresSafeArea()
            }
        }
        .sheet(item: $sheet) { route in
            switch route {
            case .order(let v):
                OrderOptionsSheet(videoId: v.id)
                    .presentationDetents([.medium, .large])
            case .recipes(let v):
                RecipesView(videoId: v.id)
                    .presentationDetents([.medium, .large])
            }
        }
        .preferredColorScheme(.dark)
        .onChange(of: currentIndex) { _ in
            preloadAroundCurrent()
            playCurrent()
        }
        .onAppear {
            preloadAroundCurrent()
            playCurrent()
        }
    }

    private func playCurrent() {
        guard feed.videos.indices.contains(currentIndex) else { return }
        let v = feed.videos[currentIndex]
        guard let url = URL(string: v.url) else { return }
        pool.pauseAll()
        pool.playKeepingMuteState(id: v.id, url: url, defaultMuted: false)
    }

    private func preloadAroundCurrent() {
        guard feed.videos.indices.contains(currentIndex) else { return }
        let idsToKeep = [-1,0,1].compactMap { offset -> String? in
            let idx = currentIndex + offset
            guard feed.videos.indices.contains(idx) else { return nil }
            let v = feed.videos[idx]
            if let url = URL(string: v.url) { pool.warm(id: v.id, url: url) }
            return v.id
        }
        pool.trim(keep: Set(idsToKeep))
        pool.pauseAll(except: Set([feed.videos[currentIndex].id]))
    }
}

struct VideoCardView: View {
    let video: Video
    let isActive: Bool

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var pool: PlayerPool

    @State private var player: AVPlayer?
    @State private var shouldPlay = true
    @State private var isMuted = false
    @State private var showHUD = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let player {
                TikTokPlayerView(player: player, isMuted: isMuted)
                    .ignoresSafeArea()
                    .onTapGesture { togglePlay() }
            }

            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(video.title)
                            .font(.headline)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(video.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .layoutPriority(1)

                    Spacer()
                    RightMetaOverlay(likes: video.like_count, comments: video.comment_count)
                }
                .padding(.horizontal)

                HStack {
                    Button {
                        isMuted.toggle()
                        player?.isMuted = isMuted
                        showTransientHUD()
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    }
                    .glassIconButton()

                    Spacer()
                    BottomActionsBar()
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            if showHUD {
                Image(systemName: shouldPlay ? "play.fill" : "pause.fill")
                    .font(.title)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Glass.strokeShape(Circle()))
                    .transition(.opacity)
            }
        }
        .contentShape(Rectangle())
        .onAppear {
            if let url = URL(string: video.url) {
                player = pool.player(for: video.id, url: url, muted: isMuted)
            }
            syncPlayback()
        }
        .onDisappear { player?.pause() }
        .onChange(of: isActive) { _ in syncPlayback() }
        .onChange(of: scenePhase) { phase in
            if phase == .active { syncPlayback() } else { player?.pause() }
        }
    }

    private func syncPlayback() {
        guard let player else { return }
        if isActive && shouldPlay { player.play() } else { player.pause() }
    }

    private func togglePlay() {
        shouldPlay.toggle()
        syncPlayback()
        showTransientHUD()
    }

    private func showTransientHUD() {
        withAnimation { showHUD = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation { showHUD = false }
        }
    }
}
