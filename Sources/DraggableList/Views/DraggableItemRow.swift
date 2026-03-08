import SwiftUI

// MARK: - DraggableItemRow

/// Internal row wrapper that manages drag gesture attachment and visual feedback.
///
/// **Key behavior:**
/// - If a `DragHandle` is present inside the row content → only the handle activates drag.
/// - If no `DragHandle` is present → the entire row activates drag.
///
/// Detection is done via `DragHandlePresentKey` (a SwiftUI PreferenceKey).
/// Drag callbacks are passed down to `DragHandle` via the `.dragActions` environment value.
struct DraggableItemRow<Item: DraggableItem, RowContent: View>: View {

    let item: Item
    let index: Int
    @Binding var items: [Item]
    @Binding var itemBinding: Item
    let frameStorage: FrameStorage
    let isDragging: Bool
    let configuration: DraggableListConfiguration
    let coordinateSpaceName: String
    @ViewBuilder let rowContent: (Binding<Item>, Bool) -> RowContent

    // MARK: - ViewModel

    @EnvironmentObject private var viewModel: DraggableListViewModel<Item>

    // MARK: - DragHandle Detection

    @State private var handleDetector = HandleDetector()

    // MARK: - Body

    var body: some View {
        let detector = handleDetector
        rowContent($itemBinding, isDragging)
            // Inject drag callbacks so DragHandle can attach its own gesture
            .environment(\.dragActions, makeDragActions())
            // Read the DragHandle preference to know if one exists in this row
            .onPreferenceChange(DragHandlePresentKey.self) { present in
                detector.hasHandle = present
            }
            // Report this row's frame for hit-testing
            .modifier(
                FrameReader(
                    id: item.id,
                    coordinateSpace: coordinateSpaceName
                )
            )
            // Full-row gesture ONLY if no DragHandle is present
            .gesture(makeDragGesture(), isEnabled: item.isDraggable && !detector.hasHandle)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
    }

    // MARK: - DragActions (for DragHandle)

    private func makeDragActions() -> DragActions {
        let longPressDuration: Double
        switch configuration.dragActivation {
        case .longPress(let duration):
            longPressDuration = duration
        case .immediate:
            longPressDuration = 0.0
        }

        return DragActions(
            longPressDuration: longPressDuration,
            minimumDistance: configuration.minimumDragDistance,
            coordinateSpaceName: coordinateSpaceName,
            onPressBegan: {
                viewModel.beginPressing(item: item)
            },
            onDragChanged: { drag in
                handleDragChanged(drag: drag)
            },
            onDragEnded: {
                viewModel.endDrag()
            }
        )
    }

    // MARK: - Full-Row Gesture (fallback when no DragHandle)

    private func makeDragGesture() -> AnyGesture<Any> {
        switch configuration.dragActivation {
        case .longPress(let duration):
            return longPressThenDrag(duration: duration)
        case .immediate:
            return immediateDrag()
        }
    }

    private func longPressThenDrag(duration: Double) -> AnyGesture<Any> {
        AnyGesture(
            LongPressGesture(minimumDuration: duration)
                .sequenced(
                    before: DragGesture(
                        minimumDistance: configuration.minimumDragDistance,
                        coordinateSpace: .named(coordinateSpaceName)
                    )
                )
                .onChanged { value in
                    switch value {
                    case .second(_, let drag):
                        if let drag = drag {
                            handleDragChanged(drag: drag)
                        } else {
                            viewModel.beginPressing(item: item)
                        }
                    default:
                        break
                    }
                }
                .onEnded { _ in
                    viewModel.endDrag()
                }
                .map { $0 as Any }
        )
    }

    private func immediateDrag() -> AnyGesture<Any> {
        AnyGesture(
            DragGesture(
                minimumDistance: configuration.minimumDragDistance,
                coordinateSpace: .named(coordinateSpaceName)
            )
            .onChanged { drag in
                handleDragChanged(drag: drag)
            }
            .onEnded { _ in
                viewModel.endDrag()
            }
            .map { $0 as Any }
        )
    }

    // MARK: - Drag Handling

    private func handleDragChanged(drag: DragGesture.Value) {
        viewModel.updateDrag(item: item)

        if let currentIndex = items.firstIndex(of: item) {
            viewModel.attemptReorder(
                items: &items,
                currentIndex: currentIndex,
                dragLocationY: drag.location.y,
                frames: frameStorage.frames
            )
        }
    }
}
