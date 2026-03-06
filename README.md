# DraggableList

A lightweight, gesture-driven SwiftUI package for building drag-to-reorder lists with smooth animations and haptic feedback. Built with Swift 6 concurrency in mind.

## Demo

<p align="center">
  <img src="https://s13.gifyu.com/images/bmSLG.gif" width="300" alt="DraggableList Demo">
</p>

## Features

- Long-press or immediate drag activation
- Smooth spring animations during reorder
- Haptic feedback on drag start
- Optional drag handle for precise control
- Pin items in place with `isDraggable`
- Move validation with `canMoveItem`
- Callbacks for move, drag start, and drag end events
- Preset configurations (default, compact, immediate)
- iOS 16+

## Installation

### Swift Package Manager

Add DraggableList to your project through Xcode:

1. Go to **File > Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/AhmedYasserAbdElrhman/DraggableList.git
   ```
3. Set the version rule to **Up to Next Major** from `0.0.1`
4. Click **Add Package**

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AhmedYasserAbdElrhman/DraggableList.git", from: "0.0.1")
]
```

Then add the product to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["DraggableList"]
)
```

## Usage

### 1. Define Your Model

Conform your model to `DraggableItem`:

```swift
import DraggableList

struct Task: DraggableItem {
    let id = UUID()
    var title: String
}
```

### 2. Basic List

```swift
@State private var tasks: [Task] = [
    Task(title: "Buy groceries"),
    Task(title: "Walk the dog"),
    Task(title: "Read a book"),
]

var body: some View {
    ScrollView {
        DraggableListView(items: $tasks) { $task, isDragging in
            Text(task.title)
                .padding()
                .background(isDragging ? Color.blue.opacity(0.2) : Color.white)
                .cornerRadius(8)
        }
        .padding()
    }
}
```

### 3. With Drag Handle

Restrict the drag gesture to a handle instead of the entire row:

```swift
DraggableListView(items: $tasks) { $task, isDragging in
    HStack {
        Text(task.title)
        Spacer()
        DragHandle()
            .foregroundColor(.secondary)
    }
    .padding()
}
```

Use a custom handle icon:

```swift
DragHandle {
    Image(systemName: "arrow.up.arrow.down")
        .foregroundColor(.gray)
}
```

### 4. With Callbacks

```swift
DraggableListView(items: $tasks) { $task, isDragging in
    TaskRow(task: $task, isDragging: isDragging)
}
.onDraggableMove { fromOffsets, toOffset in
    print("Moved from \(fromOffsets) to \(toOffset)")
}
.onDragItemStarted { item in
    print("Started dragging \(item.title)")
}
.onDragItemEnded { item in
    print("Ended dragging \(item.title)")
}
```

### 5. Move Validation

Prevent items from being moved to specific positions:

```swift
DraggableListView(items: $tasks) { $task, isDragging in
    TaskRow(task: $task, isDragging: isDragging)
}
.canMoveItem { item, targetIndex in
    // Prevent moving to the first position
    return targetIndex > 0
}
```

### 6. Pinned (Non-Draggable) Items

Override `isDraggable` to pin items in place. Pinned items cannot be dragged and are skipped as drop targets:

```swift
struct Task: DraggableItem {
    let id = UUID()
    var title: String
    var isLocked: Bool = false

    var isDraggable: Bool { !isLocked }
}
```

## Configuration

Customize behavior through `DraggableListConfiguration`:

```swift
let config = DraggableListConfiguration(
    spacing: 12,
    dragActivation: .longPress(minimumDuration: 0.3),
    hapticFeedback: true,
    minimumDragDistance: 5
)

DraggableListView(items: $tasks, configuration: config) { $task, isDragging in
    TaskRow(task: $task, isDragging: isDragging)
}
```

### Preset Configurations

| Preset | Description |
|--------|-------------|
| `.default` | Long-press activation, 8pt spacing, haptics enabled |
| `.compact` | Same as default with 4pt spacing |
| `.immediateDrag` | Drag starts on touch, no long-press required |

```swift
// Compact spacing
DraggableListView(items: $tasks, configuration: .compact) { ... }

// Immediate drag without long-press
DraggableListView(items: $tasks, configuration: .immediateDrag) { ... }
```

### Configuration Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `spacing` | `CGFloat` | `8` | Vertical spacing between rows |
| `dragActivation` | `DragActivation` | `.longPress()` | `.longPress(minimumDuration:)` or `.immediate` |
| `hapticFeedback` | `Bool` | `true` | Trigger haptic on drag start |
| `minimumDragDistance` | `CGFloat` | `5` | Minimum distance before drag is recognized |

## Requirements

- iOS 16.0+
- Swift 6.0+
- Xcode 16.0+

## Contributing

Contributions are welcome. If you'd like to contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Open a Pull Request

Please make sure your code follows the existing style and includes appropriate documentation.

## License

DraggableList is available under the MIT License. See the [LICENSE](LICENSE) file for details.
