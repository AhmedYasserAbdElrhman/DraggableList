import SwiftUI

// MARK: - FrameStorage

/// A reference-type wrapper for storing row frames.
///
/// Marked `@unchecked Sendable` so it can be mutated inside SwiftUI's
/// `onPreferenceChange` closure (which requires `@Sendable`).
/// This is safe because `onPreferenceChange` always executes on the main thread.
final class FrameStorage: @unchecked Sendable {
    var frames: [AnyHashable: CGRect] = [:]
}

// MARK: - FramePreferenceKey

/// A preference key that collects the frames of all draggable rows.
///
/// Each row reports its frame in the shared coordinate space, which is then used
/// by `DragGestureHandler` to determine the drop target during a drag operation.
struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: [AnyHashable: CGRect] { [:] }

    static func reduce(value: inout [AnyHashable: CGRect], nextValue: () -> [AnyHashable: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

// MARK: - Frame Reader Modifier

/// A view modifier that reads a view's frame in a named coordinate space
/// and reports it via `FramePreferenceKey`.
struct FrameReader<ID: Hashable>: ViewModifier {
    let id: ID
    let coordinateSpace: String

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: FramePreferenceKey.self,
                            value: [AnyHashable(id): geometry.frame(in: .named(coordinateSpace))]
                        )
                }
            )
    }
}
