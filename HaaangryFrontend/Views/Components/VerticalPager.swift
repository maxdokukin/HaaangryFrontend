import SwiftUI
import UIKit

/// A vertically paging UICollectionView that hosts SwiftUI content per page.
struct VerticalPager<Content: View>: UIViewRepresentable {
    let count: Int
    @Binding var index: Int
    private let contentProvider: (Int) -> Content

    init(count: Int, index: Binding<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.count = count
        self._index = index
        self.contentProvider = content
    }

    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        var parent: VerticalPager
        weak var collectionView: UICollectionView?

        init(_ parent: VerticalPager) { self.parent = parent }

        // DataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.contentConfiguration = UIHostingConfiguration {
                parent.contentProvider(indexPath.item)
            }
            return cell
        }

        // Delegate
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { updateIndex(from: scrollView) }
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate { updateIndex(from: scrollView) }
        }

        // Layout
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            collectionView.bounds.size
        }

        private func updateIndex(from scrollView: UIScrollView) {
            let h = max(scrollView.bounds.height, 1)
            let newIndex = Int(round(scrollView.contentOffset.y / h))
            let clamped = max(0, min(parent.count - 1, newIndex))
            if clamped != parent.index {
                parent.index = clamped
            }
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
        cv.showsVerticalScrollIndicator = false
        cv.dataSource = context.coordinator
        cv.delegate = context.coordinator
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        context.coordinator.collectionView = cv
        return cv
    }

    func updateUIView(_ uiView: UICollectionView, context: Context) {
        uiView.performBatchUpdates({
            uiView.reloadSections(IndexSet(integer: 0))
        }, completion: { _ in
            guard self.count > 0, self.index < self.count else { return }
            let target = IndexPath(item: self.index, section: 0)
            if uiView.indexPathsForVisibleItems.contains(target) == false {
                uiView.scrollToItem(at: target, at: .centeredVertically, animated: false)
            }
        })
    }
}
