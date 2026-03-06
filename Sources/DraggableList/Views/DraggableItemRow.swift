import SwiftUI

// MARK: - DraggableItemRow

/// Internal row wrapper that attaches the drag gesture to each item.
///
/// The gesture is built based on `DraggableListConfiguration.dragActivation`:
/// - `.longPress` → LongPressGesture sequenced before DragGesture
/// - `.immediate` → DragGesture only
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

    // MARK: - Body

    var body: some View {
        rowContent($itemBinding, isDragging)
            .modifier(
                FrameReader(
                    id: item.id,
                    coordinateSpace: coordinateSpaceName
                )
            )
            .gesture(makeDragGesture(), isEnabled: item.isDraggable)
    }

    // MARK: - Gesture Construction

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
