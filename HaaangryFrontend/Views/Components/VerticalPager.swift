import SwiftUI
import UIKit

/// Vertically paging UICollectionView hosting SwiftUI per page.
/// Exposes left/right swipe callbacks at the pager level to avoid per-cell conflicts.
struct VerticalPager<Content: View>: UIViewRepresentable {
    let count: Int
    @Binding var index: Int
    let onSwipeLeft: ((Int) -> Void)?
    let onSwipeRight: ((Int) -> Void)?
    private let contentProvider: (Int) -> Content

    init(
        count: Int,
        index: Binding<Int>,
        onSwipeLeft: ((Int) -> Void)? = nil,
        onSwipeRight: ((Int) -> Void)? = nil,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self.count = count
        self._index = index
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.contentProvider = content
    }

    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        var parent: VerticalPager
        weak var collectionView: UICollectionView?

        init(_ parent: VerticalPager) { self.parent = parent }

        // DataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { parent.count }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.contentConfiguration = UIHostingConfiguration { self.parent.contentProvider(indexPath.item) }
            return cell
        }

        // Delegate
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let h = max(scrollView.bounds.height, 1)
            let proposed = Int((scrollView.contentOffset.y + h * 0.5) / h)
            let clamped = max(0, min(parent.count - 1, proposed))
            if clamped != parent.index { parent.index = clamped }
        }

        // Layout
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            collectionView.bounds.size
        }

        // Helpers
        private func currentIndex() -> Int {
            guard let cv = collectionView else { return parent.index }
            let h = max(cv.bounds.height, 1)
            let proposed = Int((cv.contentOffset.y + h * 0.5) / h)
            return max(0, min(parent.count - 1, proposed))
        }

        @objc func handleSwipeLeft(_ g: UISwipeGestureRecognizer) {
            guard g.state == .ended else { return }
            let i = currentIndex()
            parent.onSwipeLeft?(i)
        }

        @objc func handleSwipeRight(_ g: UISwipeGestureRecognizer) {
            guard g.state == .ended else { return }
            let i = currentIndex()
            parent.onSwipeRight?(i)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .black
        cv.isPagingEnabled = true
        cv.isDirectionalLockEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        cv.dataSource = context.coordinator
        cv.delegate = context.coordinator
        context.coordinator.collectionView = cv

        // Pager-level swipe recognizers. Make vertical pan wait for a horizontal swipe decision.
        let left = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipeLeft(_:)))
        left.direction = .left
        left.cancelsTouchesInView = false

        let right = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleSwipeRight(_:)))
        right.direction = .right
        right.cancelsTouchesInView = false

        cv.addGestureRecognizer(left)
        cv.addGestureRecognizer(right)

        cv.panGestureRecognizer.require(toFail: left)
        cv.panGestureRecognizer.require(toFail: right)

        return cv
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        let needsReload = uiView.numberOfItems(inSection: 0) != count
        if needsReload { uiView.reloadData() }

        guard count > 0, index < count else { return }
        let target = IndexPath(item: index, section: 0)
        if uiView.indexPathsForVisibleItems.contains(target) == false {
            uiView.scrollToItem(at: target, at: .centeredVertically, animated: false)
        }
    }
}
