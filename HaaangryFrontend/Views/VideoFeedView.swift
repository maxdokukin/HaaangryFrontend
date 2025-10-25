import SwiftUI
import AVFoundation

struct VideoFeedView: View {
    @EnvironmentObject var feed: FeedStore
    @EnvironmentObject var orders: OrderStore

    @State private var showingOrder = false
    @State private var showingRecipes = false
    @State private var selectedVideo: Video?
    @State private var currentIndex: Int = 0

    @StateObject private var pool = PlayerPool()

    var body: some View {
        ZStack {
            if feed.videos.isEmpty {
                ProgressView().task { await feed.load() }
            } else {
                VerticalPager(count: feed.videos.count, index: $currentIndex) { i in
                    VideoCardView(
                        video: feed.videos[i],
                        isActive: i == currentIndex,
                        onSwipeLeft: {
                            selectedVideo = feed.videos[i]
                            showingRecipes = true
                        },
                        onSwipeRight: {
                            selectedVideo = feed.videos[i]
                            showingOrder = true
                        }
                    )
                    .environmentObject(pool)
                    .ignoresSafeArea()
                }
                .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showingOrder) {
            if let v = selectedVideo {
                OrderOptionsSheet(videoId: v.id)
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $showingRecipes) {
            if let v = selectedVideo {
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
        // Ensure only the active one plays
        pool.pauseAll()
        _ = pool.play(id: v.id, url: url, muted: true)
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
    var onSwipeLeft: (() -> Void)? = nil
    var onSwipeRight: (() -> Void)? = nil

    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var pool: PlayerPool

    @State private var player: AVPlayer?
    @State private var shouldPlay = true
    @State private var isMuted = true
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
                        Text(video.title).font(.headline)
                        Text(video.description).font(.subheadline).foregroundStyle(.secondary)
                    }
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
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }

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
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .transition(.opacity)
            }
        }
        .onAppear {
            if let url = URL(string: video.url) {
                // Reuse or create player now so FeedView can start it immediately
                player = pool.player(for: video.id, url: url, muted: isMuted)
            }
            syncPlayback()
        }
        .onDisappear { player?.pause() }
        .onChange(of: isActive) { _ in syncPlayback() }
        .onChange(of: scenePhase) { phase in
            if phase == .active { syncPlayback() } else { player?.pause() }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    guard isActive else { return }
                    let dx = value.translation.width, dy = value.translation.height
                    if abs(dx) > abs(dy), abs(dx) > 80 {
                        if dx > 0 { onSwipeRight?() } else { onSwipeLeft?() }
                    }
                }
        )
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
