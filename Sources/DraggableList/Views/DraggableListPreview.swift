import SwiftUI

// MARK: - Preview Model

private struct PreviewTask: DraggableItem {
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

// MARK: - Previews

@available(iOS 16.0, *)
struct DraggableListView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State private var tasks: [PreviewTask] = [
            PreviewTask(title: "Design new feature", subtitle: "Due tomorrow", colorName: "purple"),
            PreviewTask(title: "Code review", subtitle: "PR #142", colorName: "blue"),
            PreviewTask(title: "Write documentation", subtitle: "API guide", colorName: "green"),
            PreviewTask(title: "Fix login bug", subtitle: "Critical", colorName: "red"),
            PreviewTask(title: "Team standup", subtitle: "10:00 AM", colorName: "orange"),
            PreviewTask(title: "Deploy to staging", subtitle: "v2.1.0", colorName: "teal"),
        ]

        var body: some View {
            NavigationView {
                ScrollView {
                    DraggableListView(items: $tasks) { $task, isDragging in
                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(task.color)
                                .frame(width: 4, height: 40)

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

                            DragHandle()
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isDragging ? Color(.systemGray5) : Color(.systemBackground))
                                .shadow(
                                    color: isDragging ? .black.opacity(0.15) : .black.opacity(0.05),
                                    radius: isDragging ? 8 : 2,
                                    y: isDragging ? 4 : 1
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                    }
                    .padding()
                }
                .navigationTitle("DraggableList")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
