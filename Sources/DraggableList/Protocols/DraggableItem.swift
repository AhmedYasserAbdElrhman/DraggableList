import Foundation

// MARK: - DraggableItem Protocol

/// A protocol that defines the requirements for items that can be used in a `DraggableListView`.
///
/// Conform your model type to `DraggableItem` to make it compatible with the draggable list system.
/// The protocol extends `Identifiable` (for stable identity during reordering) and `Equatable`
/// (for change detection and animation).
///
/// ## Example
/// ```swift
/// struct Task: DraggableItem {
///     let id = UUID()
///     var title: String
///     var isDraggable: Bool { !isLocked }
///     var isLocked: Bool = false
/// }
/// ```
///
/// By default, all items are draggable. Override `isDraggable` to pin specific items in place.
public protocol DraggableItem: Identifiable, Equatable, Sendable {

    /// Indicates whether this item can be reordered by dragging.
    ///
    /// Return `false` to prevent users from dragging this item.
    /// Non-draggable items remain in their position and are skipped as drop targets.
    ///
    /// The default implementation returns `true`.
    var isDraggable: Bool { get }
}

// MARK: - Default Implementation

public extension DraggableItem {
    var isDraggable: Bool { true }
}
