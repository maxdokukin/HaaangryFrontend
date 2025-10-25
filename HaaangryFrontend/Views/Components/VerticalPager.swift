import SwiftUI
import UIKit

/// Vertically paging UICollectionView hosting SwiftUI per page.
/// Updates `index` continuously as you cross 50% of a page.
struct VerticalPager<Content: View>: UIViewRepresentable {
    let count: Int
    @Binding var index: Int
    private let contentProvider: (Int) -> Content

    init(count: Int, index: Binding<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self.count = count
        self._index = index
        self.contentProvider = content
    }

    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
        var parent: VerticalPager
        weak var collectionView: UICollectionView?
        private var horizontalGate: UIPanGestureRecognizer?

        init(_ parent: VerticalPager) { self.parent = parent }

        // MARK: DataSource
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { parent.count }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            cell.contentConfiguration = UIHostingConfiguration { self.parent.contentProvider(indexPath.item) }
            return cell
        }

        // MARK: Delegate
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let h = max(scrollView.bounds.height, 1)
            let proposed = Int((scrollView.contentOffset.y + h * 0.5) / h)
            let clamped = max(0, min(parent.count - 1, proposed))
            if clamped != parent.index { parent.index = clamped }
        }

        // MARK: Layout
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            collectionView.bounds.size
        }

        // MARK: Horizontal gate recognizer
        func attachHorizontalGate(to cv: UICollectionView) {
            // No-op target; we only need recognition, not handling.
            let gate = UIPanGestureRecognizer(target: self, action: #selector(handleHorizontalGate(_:)))
            gate.minimumNumberOfTouches = 1
            gate.maximumNumberOfTouches = 1
            gate.cancelsTouchesInView = false // allow SwiftUI gestures to still receive touches
            gate.delegate = self

            cv.addGestureRecognizer(gate)
            // Make the scroll view pan wait to see if horizontal wins.
            cv.panGestureRecognizer.require(toFail: gate)

            self.collectionView = cv
            self.horizontalGate = gate
        }

        @objc private func handleHorizontalGate(_ g: UIPanGestureRecognizer) {
            // Intentionally empty.
        }

        // Only begin our gate on horizontal pans.
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard gestureRecognizer === horizontalGate,
                  let pan = gestureRecognizer as? UIPanGestureRecognizer,
                  let view = pan.view
            else { return true }
            let v = pan.velocity(in: view)
            // Prefer horizontal only if clearly dominant.
            return abs(v.x) > abs(v.y)
        }

        // Allow our gate to recognize alongside SwiftUI’s DragGesture recognizers.
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // Never touch the scroll view’s built-in pan delegate.
            guard gestureRecognizer === horizontalGate else { return false }
            // Permit simultaneous recognition so SwiftUI can receive its drag.
            return true
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
        cv.isDirectionalLockEnabled = true
        cv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")

        cv.dataSource = context.coordinator
        cv.delegate = context.coordinator

        // Install the horizontal gate without touching cv.panGestureRecognizer.delegate.
        context.coordinator.attachHorizontalGate(to: cv)

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
