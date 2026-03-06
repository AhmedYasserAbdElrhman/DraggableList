import SwiftUI

// MARK: - DragHandle

/// A view that serves as the drag handle within a draggable list row.
///
/// When a `DragHandle` is placed inside the row content of a `DraggableListView`,
/// only the handle region activates the drag gesture (instead of the entire row).
///
/// ## Usage with Default Icon
/// ```swift
/// DraggableListView(items: $items) { $item, isDragging in
///     HStack {
///         Text(item.title)
///         Spacer()
///         DragHandle()
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

    public var body: some View {
        label
            .contentShape(Rectangle())
    }
}

// MARK: - Default Icon Convenience

public extension DragHandle where Label == Image {

    /// Creates a drag handle with the default grip icon (SF Symbol `line.3.horizontal`).
    init() {
        self.label = Image(systemName: "line.3.horizontal")
    }
}

// MARK: - Environment Key for Handle Detection

/// Environment key to signal that a `DragHandle` is present in the row,
/// so the gesture is attached only to the handle rather than the full row.
struct DragHandleActiveKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var isDragHandleActive: Bool {
        get { self[DragHandleActiveKey.self] }
        set { self[DragHandleActiveKey.self] = newValue }
    }
}
