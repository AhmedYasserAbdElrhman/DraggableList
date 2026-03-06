import SwiftUI

// MARK: - DraggableListViewModel

/// Manages drag state for a `DraggableListView`.
///
/// The ViewModel does **not** own the items array — the parent view's `@Binding`
/// remains the single source of truth. The ViewModel only manages:
/// - `DragState` lifecycle (inactive → pressing → dragging → inactive)
/// - Haptic feedback
///
/// Frame storage is handled by the view layer via `@State` to avoid
/// Swift 6 `@Sendable` closure issues with `onPreferenceChange`.
final class DraggableListViewModel<Item: DraggableItem>: ObservableObject {

    // MARK: - Published State

    @Published var dragState: DragState<Item> = .inactive

    // MARK: - Dependencies

    let configuration: DraggableListConfiguration
    let gestureHandler = DragGestureHandler<Item>()

    // MARK: - Callbacks (set by the parent view)

    var onMove: ((IndexSet, Int) -> Void)?
    var onDragStarted: ((Item) -> Void)?
    var onDragEnded: ((Item) -> Void)?
    var canMoveItem: ((Item, Int) -> Bool)?

    // MARK: - Private State

    private var hasStartedDragging = false

    // MARK: - Init

    init(configuration: DraggableListConfiguration) {
        self.configuration = configuration
    }

    // MARK: - Drag Lifecycle

    /// Called when the user long-presses an item.
    func beginPressing(item: Item) {
        guard item.isDraggable else { return }
        dragState = .pressing(item: item)
        hasStartedDragging = false

        if configuration.hapticFeedback {
            triggerHaptic()
        }
    }

    /// Called when the drag gesture updates.
    func updateDrag(item: Item) {
        guard item.isDraggable else { return }

        if !hasStartedDragging {
            hasStartedDragging = true
            onDragStarted?(item)
            dragState = .dragging(item: item)
        }
    }

    /// Called when the drag gesture ends.
    func endDrag() {
        if let item = dragState.activeItem, hasStartedDragging {
            onDragEnded?(item)
        }
        dragState = .inactive
        hasStartedDragging = false
    }

    /// Attempts a reorder by finding the target index and mutating items.
    func attemptReorder(
        items: inout [Item],
        currentIndex: Int,
        dragLocationY: CGFloat,
        frames: [AnyHashable: CGRect]
    ) {
        guard let targetIndex = gestureHandler.findTargetIndex(
            currentIndex: currentIndex,
            dragLocationY: dragLocationY,
            items: items,
            frames: frames,
            canMove: canMoveItem
        ) else { return }

        guard gestureHandler.canMove(from: currentIndex, to: targetIndex, in: items) else { return }

        let from = IndexSet(integer: currentIndex)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            items.move(fromOffsets: from, toOffset: targetIndex)
        }

        onMove?(from, targetIndex)
    }

    /// Whether a specific item is currently being dragged.
    func isDragging(item: Item) -> Bool {
        dragState.activeItem == item && (dragState.isDragging || dragState.isPressing)
    }

    // MARK: - Haptics

    private func triggerHaptic() {
        Task { @MainActor in
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}
