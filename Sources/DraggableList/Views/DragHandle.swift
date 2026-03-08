import SwiftUI

// MARK: - DragHandle

/// A view that serves as the drag activation region within a draggable list row.
///
/// When a `DragHandle` is placed inside the row content of a `DraggableListView`,
/// **only the handle region activates the drag gesture** (instead of the entire row).
/// If no `DragHandle` is present in a row, the entire row is draggable by default.
///
/// ## Usage with Default Icon
/// ```swift
/// DraggableListView(items: $items) { $item, isDragging in
///     HStack {
///         Text(item.title)
///         Spacer()
///         DragHandle()  // Only this region activates drag
///     }
/// }
/// ```
///
/// ## Usage with Custom Label
/// ```swift
/// DragHandle {
///     Image(systemName: "arrow.up.arrow.down")
///         .foregroundColor(.gray)
/// }
/// ```
public struct DragHandle<Label: View>: View {

    let label: Label

    /// Creates a drag handle with a custom label.
    ///
    /// - Parameter label: A view builder that produces the visual content of the handle.
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }

    // MARK: - Environment

    @Environment(\.dragActions) private var dragActions

    // MARK: - Body

    public var body: some View {
        label
            .contentShape(Rectangle())
            .gesture(dragGesture, isEnabled: dragActions != nil)
            // Report presence of DragHandle to parent via preference
            .preference(key: DragHandlePresentKey.self, value: true)
    }

    // MARK: - Gesture

    private var dragGesture: some Gesture {
        LongPressGesture(minimumDuration: dragActions?.longPressDuration ?? 0.3)
            .sequenced(
                before: DragGesture(
                    minimumDistance: dragActions?.minimumDistance ?? 0,
                    coordinateSpace: .named(dragActions?.coordinateSpaceName ?? "")
                )
            )
            .onChanged { value in
                switch value {
                case .second(_, let drag):
                    if let drag = drag {
                        dragActions?.onDragChanged(drag)
                    } else {
                        dragActions?.onPressBegan()
                    }
                default:
                    break
                }
            }
            .onEnded { _ in
                dragActions?.onDragEnded()
            }
    }
}

// MARK: - Default Icon Convenience

public extension DragHandle where Label == Image {

    /// Creates a drag handle with the default grip icon (SF Symbol `line.3.horizontal`).
    init() {
        self.label = Image(systemName: "line.3.horizontal")
    }
}

// MARK: - HandleDetector

/// A reference-type wrapper for detecting `DragHandle` presence.
///
/// Uses `@unchecked Sendable` to work inside `onPreferenceChange`'s `@Sendable` closure.
/// Safe because SwiftUI always calls `onPreferenceChange` on the main thread.
final class HandleDetector: @unchecked Sendable {
    var hasHandle: Bool = false
}

// MARK: - DragHandlePresentKey

/// PreferenceKey that reports whether a `DragHandle` exists in a row.
/// Used by `DraggableItemRow` to decide whether to attach a full-row gesture.
struct DragHandlePresentKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: Bool = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// MARK: - DragActions

/// Holds the drag callbacks and configuration that `DragHandle` needs
/// to attach its own gesture. Passed down via the SwiftUI environment.
struct DragActions: @unchecked Sendable {
    let longPressDuration: Double
    let minimumDistance: CGFloat
    let coordinateSpaceName: String
    let onPressBegan: () -> Void
    let onDragChanged: (DragGesture.Value) -> Void
    let onDragEnded: () -> Void
}

// MARK: - Environment Key

struct DragActionsKey: EnvironmentKey {
    static let defaultValue: DragActions? = nil
}

extension EnvironmentValues {
    var dragActions: DragActions? {
        get { self[DragActionsKey.self] }
        set { self[DragActionsKey.self] = newValue }
    }
}
