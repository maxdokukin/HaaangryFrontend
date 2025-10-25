// Views/VideoFeedView.swift
import SwiftUI
import AVFoundation

struct VideoFeedView: View {
    @EnvironmentObject var feed: FeedStore
    @EnvironmentObject var orders: OrderStore

    @State private var showingOrder = false
    @State private var showingRecipes = false
    @State private var selectedVideo: Video?

    @State private var currentIndex: Int = 0
    @State private var verticalDragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if feed.videos.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .task { await feed.load() }
                } else {
                    ZStack {
                        ForEach(feed.videos.indices, id: \.self) { i in
                            let v = feed.videos[i]
                            VideoCardView(video: v, isActive: i == currentIndex)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .offset(y: CGFloat(i - currentIndex) * geo.size.height + verticalDragOffset)
                                .animation(.interactiveSpring(), value: currentIndex)
                                .animation(.interactiveSpring(), value: verticalDragOffset)
                                .zIndex(i == currentIndex ? 1 : 0)
                        }
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onChanged { value in
                                if abs(value.translation.height) > abs(value.translation.width) {
                                    verticalDragOffset = value.translation.height
                                } else {
                                    verticalDragOffset = 0
                                }
                            }
                            .onEnded { value in
                                let dx = value.translation.width
                                let dy = value.translation.height
                                defer { verticalDragOffset = 0 }

                                // Horizontal: left = recipes, right = order
                                if abs(dx) > abs(dy) {
                                    if dx > 80 {
                                        selectedVideo = feed.videos[currentIndex]
                                        showingOrder = true
                                    } else if dx < -80 {
                                        selectedVideo = feed.videos[currentIndex]
                                        showingRecipes = true
                                    }
                                    return
                                }

                                // Vertical cards: swipe down → next, up → previous
                                if dy > 80, currentIndex < feed.videos.count - 1 {
                                    currentIndex += 1
                                } else if dy < -80, currentIndex > 0 {
                                    currentIndex -= 1
                                }
                            }
                    )
                }
            }
            .ignoresSafeArea()
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
    }
}

struct VideoCardView: View {
    let video: Video
    let isActive: Bool

    @Environment(\.scenePhase) private var scenePhase
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
                    .onTapGesture {
                        togglePlay()
                    }
            }

            // Minimal overlay UI
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
                        showTransientHUD()
                        player?.isMuted = isMuted
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
            if player == nil, let url = URL(string: video.url) {
                let p = AVPlayer(url: url)
                p.isMuted = isMuted
                player = p
            }
            syncPlayback()
        }
        .onDisappear {
            player?.pause()
        }
        .onChange(of: isActive) { _ in
            syncPlayback()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                syncPlayback()
            } else {
                player?.pause()
            }
        }
    }

    private func syncPlayback() {
        guard let player else { return }
        if isActive && shouldPlay {
            player.play()
        } else {
            player.pause()
        }
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
