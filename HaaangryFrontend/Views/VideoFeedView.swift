import SwiftUI
import AVKit

struct VideoFeedView: View {
    @EnvironmentObject var feed: FeedStore
    @EnvironmentObject var orders: OrderStore
    @State private var showingOrder = false
    @State private var showingRecipes = false
    @State private var selectedVideo: Video?

    var body: some View {
        GeometryReader { geo in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(feed.videos) { video in
                        VideoCardView(video: video)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 20)
                                    .onEnded { value in
                                        if value.translation.width > 80 {
                                            selectedVideo = video
                                            showingOrder = true
                                        } else if value.translation.width < -80 {
                                            selectedVideo = video
                                            showingRecipes = true
                                        }
                                    }
                            )
                    }
                }
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
    }
}

struct VideoCardView: View {
    let video: Video
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .onAppear {
                    player = AVPlayer(url: URL(string: video.url)!)
                    player?.play()
                }
                .onDisappear { player?.pause() }
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
                BottomActionsBar()
            }
        }
    }
}
