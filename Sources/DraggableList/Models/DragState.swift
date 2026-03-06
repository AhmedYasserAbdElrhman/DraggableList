import SwiftUI

// MARK: - DragState

/// Represents the current state of a drag interaction within the draggable list.
///
/// This enum tracks the lifecycle of a drag operation from inactive → pressing → dragging → inactive.
enum DragState<Item: DraggableItem>: Equatable, Sendable {

    /// No drag is in progress.
    case inactive

    /// The user is pressing an item (long-press recognized, drag not yet started).
    case pressing(item: Item)

    /// The user is actively dragging an item.
    case dragging(item: Item)

    // MARK: - Computed Properties

    /// The item currently being interacted with, if any.
    var activeItem: Item? {
        switch self {
        case .inactive:
            return nil
        case .pressing(let item):
            return item
        case .dragging(let item):
            return item
        }
    }

    /// Whether a drag is actively in progress.
    var isDragging: Bool {
        if case .dragging = self { return true }
        return false
    }

    /// Whether the user is currently pressing (but not yet dragging).
    var isPressing: Bool {
        if case .pressing = self { return true }
        return false
    }

    // MARK: - Equatable

    static func == (lhs: DragState, rhs: DragState) -> Bool {
        switch (lhs, rhs) {
        case (.inactive, .inactive):
            return true
        case (.pressing(let lItem), .pressing(let rItem)):
            return lItem == rItem
        case (.dragging(let lItem), .dragging(let rItem)):
            return lItem == rItem
        default:
            return false
        }
    }
}
