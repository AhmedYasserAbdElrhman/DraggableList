import SwiftUI

// MARK: - DraggableListView

/// A generic, reusable SwiftUI view for creating drag-to-reorder lists.
///
/// `DraggableListView` takes a binding to an array of items conforming to `DraggableItem`
/// and renders each item using a `@ViewBuilder` closure. Users can long-press (or immediately grab,
/// depending on configuration) items to reorder them via drag gestures.
///
/// ## Basic Usage
/// ```swift
/// struct Task: DraggableItem {
///     let id = UUID()
///     var title: String
/// }
///
/// @State private var tasks: [Task] = [
///     Task(title: "Buy groceries"),
///     Task(title: "Walk the dog"),
///     Task(title: "Read a book"),
/// ]
///
/// DraggableListView(items: $tasks) { $task, isDragging in
///     Text(task.title)
///         .padding()
///         .background(isDragging ? Color.blue.opacity(0.2) : Color.white)
///         .cornerRadius(8)
/// }
/// ```
///
/// ## With Drag Handle
/// ```swift
/// DraggableListView(items: $tasks) { $task, isDragging in
///     HStack {
///         Text(task.title)
///         Spacer()
///         DragHandle()
///     }
///     .padding()
/// }
/// ```
///
/// ## With Callbacks
/// ```swift
/// DraggableListView(items: $tasks) { $task, isDragging in
///     TaskRow(task: $task)
/// }
/// .onDraggableMove { fromOffsets, toOffset in
///     print("Moved from \(fromOffsets) to \(toOffset)")
/// }
/// .onDragItemStarted { item in
///     print("Started dragging \(item.title)")
/// }
/// .onDragItemEnded { item in
///     print("Ended dragging \(item.title)")
/// }
/// ```
public struct DraggableListView<Item: DraggableItem, RowContent: View>: View {

    // MARK: - Properties

    @Binding var items: [Item]
    let configuration: DraggableListConfiguration

    @ViewBuilder let rowContent: (Binding<Item>, Bool) -> RowContent

    // MARK: - Internal State

    @StateObject private var viewModel: DraggableListViewModel<Item>

    /// Frame storage using `@unchecked Sendable` wrapper so `onPreferenceChange`
    /// (which requires a `@Sendable` closure) can update it.
    /// This is safe because SwiftUI always calls `onPreferenceChange` on the main thread.
    @State private var frameStorage = FrameStorage()

    // MARK: - Callback Storage

    private var onMove: ((IndexSet, Int) -> Void)?
    private var onDragStarted: ((Item) -> Void)?
    private var onDragEnded: ((Item) -> Void)?
    private var canMoveItem: ((Item, Int) -> Bool)?

    // MARK: - Coordinate Space

    private let coordinateSpaceName = "DraggableListCoordinateSpace"

    // MARK: - Initializer

    /// Creates a draggable list view.
    ///
    /// - Parameters:
    ///   - items: A binding to the array of items to display and reorder.
    ///   - configuration: Configuration for visual and behavioral properties. Defaults to `.default`.
    ///   - rowContent: A view builder that produces the content for each row.
    ///     - The first parameter is a binding to the item, allowing in-place editing.
    ///     - The second parameter is a `Bool` indicating whether the item is currently being dragged.
    public init(
        items: Binding<[Item]>,
        configuration: DraggableListConfiguration = .default,
        @ViewBuilder rowContent: @escaping (Binding<Item>, Bool) -> RowContent
    ) {
        _items = items
        self.configuration = configuration
        self.rowContent = rowContent
        _viewModel = StateObject(wrappedValue: DraggableListViewModel(configuration: configuration))
    }

    // MARK: - Body

    public var body: some View {
        let _ = configureCallbacks()
        let storage = frameStorage
        VStack(spacing: configuration.spacing) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                DraggableItemRow(
                    item: item,
                    index: index,
                    items: $items,
                    itemBinding: $items[index],
                    frameStorage: storage,
                    isDragging: viewModel.isDragging(item: item),
                    configuration: configuration,
                    coordinateSpaceName: coordinateSpaceName,
                    rowContent: rowContent
                )
                .id(item.id)
                .animation(.linear, value: items)
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .onPreferenceChange(FramePreferenceKey.self) { newFrames in
            storage.frames = newFrames
        }
        .environmentObject(viewModel)
    }

    // MARK: - Callback Configuration

    @discardableResult
    private func configureCallbacks() -> Bool {
        viewModel.onMove = onMove
        viewModel.onDragStarted = onDragStarted
        viewModel.onDragEnded = onDragEnded
        viewModel.canMoveItem = canMoveItem
        return true
    }
}

// MARK: - View Modifiers (Fluent API)

public extension DraggableListView {

    /// Adds a callback that is invoked when items are moved.
    ///
    /// - Parameter action: A closure receiving the source offsets and destination offset.
    /// - Returns: A modified copy of this view.
    func onDraggableMove(_ action: @escaping (IndexSet, Int) -> Void) -> Self {
        var copy = self
        copy.onMove = action
        return copy
    }

    /// Adds a callback that is invoked when a drag operation starts.
    ///
    /// - Parameter action: A closure receiving the item being dragged.
    /// - Returns: A modified copy of this view.
    func onDragItemStarted(_ action: @escaping (Item) -> Void) -> Self {
        var copy = self
        copy.onDragStarted = action
        return copy
    }

    /// Adds a callback that is invoked when a drag operation ends.
    ///
    /// - Parameter action: A closure receiving the item that was dragged.
    /// - Returns: A modified copy of this view.
    func onDragItemEnded(_ action: @escaping (Item) -> Void) -> Self {
        var copy = self
        copy.onDragEnded = action
        return copy
    }

    /// Adds a validation closure that determines whether an item can be moved to a specific index.
    ///
    /// - Parameter predicate: A closure receiving the item and the proposed target index.
    ///   Return `true` to allow the move, `false` to prevent it.
    /// - Returns: A modified copy of this view.
    func canMoveItem(_ predicate: @escaping (Item, Int) -> Bool) -> Self {
        var copy = self
        copy.canMoveItem = predicate
        return copy
    }
}
