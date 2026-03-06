import SwiftUI

// MARK: - Drag Activation Mode

/// Defines how the drag gesture is activated.
public enum DragActivation: Sendable {

    /// Drag starts after a long press of the specified duration.
    /// This is the default behavior, matching the common iOS drag-to-reorder pattern.
    case longPress(minimumDuration: Double = 0.2)

    /// Drag starts immediately on touch-down and movement.
    case immediate
}

// MARK: - DraggableListConfiguration

/// Configuration for the visual and behavioral properties of a `DraggableListView`.
///
/// Use this to customize spacing, drag activation, visual feedback, and animations.
///
/// ## Example
/// ```swift
/// let config = DraggableListConfiguration(
///     spacing: 12,
///     dragActivation: .longPress(minimumDuration: 0.3),
///     hapticFeedback: true
/// )
///
/// DraggableListView(items: $tasks, configuration: config) { $task, isDragging in
///     TaskRow(task: $task)
/// }
/// ```
public struct DraggableListConfiguration: Sendable {

    /// The vertical spacing between rows.
    public var spacing: CGFloat

    /// How the drag gesture is activated.
    public var dragActivation: DragActivation

    /// Whether haptic feedback is triggered when dragging begins.
    public var hapticFeedback: Bool

    /// The minimum drag distance before the gesture is recognized.
    public var minimumDragDistance: CGFloat

    /// Creates a configuration with the specified values.
    ///
    /// All parameters have sensible defaults for a standard drag-to-reorder experience.
    public init(
        spacing: CGFloat = 8,
        dragActivation: DragActivation = .longPress(),
        hapticFeedback: Bool = true,
        minimumDragDistance: CGFloat = 5
    ) {
        self.spacing = spacing
        self.dragActivation = dragActivation
        self.hapticFeedback = hapticFeedback
        self.minimumDragDistance = minimumDragDistance
    }
}

// MARK: - Preset Configurations

public extension DraggableListConfiguration {

    /// The default configuration with long-press activation.
    static let `default` = DraggableListConfiguration()

    /// A compact configuration with smaller spacing.
    static let compact = DraggableListConfiguration(
        spacing: 4
    )

    /// A configuration with immediate drag activation (no long-press required).
    static let immediateDrag = DraggableListConfiguration(
        dragActivation: .immediate
    )
}
