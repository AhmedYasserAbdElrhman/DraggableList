import SwiftUI

// MARK: - DragGestureHandler

/// Pure-logic handler that computes reorder operations during a drag.
///
/// This type contains no UI code — it takes geometry data and drag position
/// and returns the target index for a potential reorder, respecting item draggability constraints.
struct DragGestureHandler<Item: DraggableItem> {

    /// Finds the target index for the currently dragged item.
    ///
    /// - Parameters:
    ///   - currentIndex: The current index of the dragged item.
    ///   - dragLocationY: The Y position of the drag in the coordinate space.
    ///   - items: The current list of items.
    ///   - frames: A dictionary mapping item IDs to their frames.
    ///   - canMove: Optional closure to validate if a move to a given index is allowed.
    /// - Returns: The target index for the reorder, or `nil` if no valid target exists.
    func findTargetIndex(
        currentIndex: Int,
        dragLocationY: CGFloat,
        items: [Item],
        frames: [AnyHashable: CGRect],
        canMove: ((Item, Int) -> Bool)?
    ) -> Int? {
        guard currentIndex >= 0, currentIndex < items.count else { return nil }

        let currentItem = items[currentIndex]
        
        var maxDownTarget: Int?
        var minUpTarget: Int?

        // Check each item's midY to see if the drag location has crossed it
        for (index, item) in items.enumerated() {
            guard index != currentIndex else { continue }
            guard item.isDraggable else { continue }

            guard let frame = frames[AnyHashable(item.id)] else { continue }

            if index > currentIndex {
                // Dragging down: check if we crossed the midpoint
                if dragLocationY > frame.midY {
                    maxDownTarget = max(maxDownTarget ?? -1, index + 1)
                }
            } else if index < currentIndex {
                // Dragging up: check if we crossed the midpoint
                if dragLocationY < frame.midY {
                    minUpTarget = min(minUpTarget ?? Int.max, index)
                }
            }
        }

        // Determine the target based on direction.
        // If frames intersect heavily, both could be non-nil. Prefer the one closer to currentIndex.
        var targetIndex: Int?
        
        if let down = maxDownTarget, let up = minUpTarget {
            if (down - currentIndex) <= (currentIndex - up) {
                targetIndex = down
            } else {
                targetIndex = up
            }
        } else {
            targetIndex = maxDownTarget ?? minUpTarget
        }

        guard let target = targetIndex else { return nil }

        // Validate move if a constraint is provided
        if let canMove = canMove, !canMove(currentItem, target) {
            return nil
        }

        return target
    }

    /// Checks whether moving from `sourceIndex` to `targetIndex` is valid.
    ///
    /// A move is invalid if:
    /// - The source item is not draggable
    /// - Any non-draggable item sits between source and normalized target
    func canMove(from sourceIndex: Int, to targetIndex: Int, in items: [Item]) -> Bool {
        guard sourceIndex >= 0, sourceIndex < items.count else { return false }

        // Don't allow moving non-draggable items
        guard items[sourceIndex].isDraggable else { return false }

        let normalizedTarget = targetIndex > sourceIndex ? targetIndex - 1 : targetIndex
        guard normalizedTarget >= 0, normalizedTarget < items.count else { return false }

        // Don't allow moving to a non-draggable item's position
        if !items[normalizedTarget].isDraggable && normalizedTarget != sourceIndex {
            return false
        }

        // Check for non-draggable items in the path
        let range = min(sourceIndex, normalizedTarget)...max(sourceIndex, normalizedTarget)
        for i in range {
            if !items[i].isDraggable && i != sourceIndex {
                return false
            }
        }

        return true
    }

    // MARK: - Private Helpers

    /// Returns frames ordered by their position in the items array.
    private func orderedFrames(
        items: [Item],
        frames: [AnyHashable: CGRect]
    ) -> [(index: Int, frame: CGRect)] {
        items.enumerated().compactMap { index, item in
            guard let frame = frames[AnyHashable(item.id)] else { return nil }
            return (index: index, frame: frame)
        }
    }
}
