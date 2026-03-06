import SwiftUI
import DraggableList

// MARK: - Sample Item

struct SampleTask: DraggableItem {
    let id: UUID
    var title: String
    var subtitle: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String = "",
        colorName: String = "blue"
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.colorName = colorName
    }

    var color: Color {
        switch colorName {
        case "purple": return .purple
        case "blue": return .blue
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        case "teal": return .teal
        default: return .gray
        }
    }
}

// MARK: - Content View

struct ContentView: View {

    @State private var tasks: [SampleTask] = [
        SampleTask(title: "Design new feature", subtitle: "Due tomorrow", colorName: "purple"),
        SampleTask(title: "Code review", subtitle: "PR #142", colorName: "blue"),
        SampleTask(title: "Write documentation", subtitle: "API guide", colorName: "green"),
        SampleTask(title: "Fix login bug", subtitle: "Critical", colorName: "red"),
        SampleTask(title: "Team standup", subtitle: "10:00 AM", colorName: "orange"),
        SampleTask(title: "Deploy to staging", subtitle: "v2.1.0", colorName: "teal"),
    ]

    @State private var lastAction: String = "Long press and drag to reorder"

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Status bar
                Text(lastAction)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))

                ScrollView {
                    DraggableListView(items: $tasks) { $task, isDragging in
                        taskRow(task: task, isDragging: isDragging)
                    }
                    .onDraggableMove { from, to in
                        lastAction = "Moved from index \(from.first ?? 0) to \(to)"
                    }
                    .onDragItemStarted { item in
                        lastAction = "Dragging: \(item.title)"
                    }
                    .onDragItemEnded { _ in
                        lastAction = "Drop complete ✓"
                    }
                    .padding()
                }
            }
            .navigationTitle("DraggableList Demo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Row View

    @ViewBuilder
    private func taskRow(task: SampleTask, isDragging: Bool) -> some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(task.color)
                .frame(width: 4, height: 40)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body.weight(.medium))
                if !task.subtitle.isEmpty {
                    Text(task.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Drag handle
            DragHandle()
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isDragging ? Color(.systemGray5) : Color(.systemBackground))
                .shadow(
                    color: isDragging ? Color.black.opacity(0.15) : Color.black.opacity(0.05),
                    radius: isDragging ? 8 : 2,
                    y: isDragging ? 4 : 1
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
}
