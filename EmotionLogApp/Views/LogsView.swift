import Foundation
import SwiftData
import SwiftUI

struct LogsView: View {
    @Query(sort: \EmotionLog.date, order: .reverse) private var emotionLogs: [EmotionLog]
    @Query private var emotions: [Emotion]

    var body: some View {
        NavigationStack {
            Group {
                if emotionLogs.isEmpty {
                    ContentUnavailableView(
                        "No Logs",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Saved emotion logs will appear here.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(emotionLogs) { log in
                                logCard(for: log)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Logs")
        }
    }

    private func logCard(for log: EmotionLog) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(Self.dateFormatter.string(from: log.date))
                    .font(.headline)

                Spacer()

                Text(Self.timeFormatter.string(from: log.date))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            emotionChips(for: log)

            if !log.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(log.memo)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
    }

    private func emotionChips(for log: EmotionLog) -> some View {
        let selectedEmotions = log.selectedEmotionIds.compactMap { emotion(for: $0) }

        return FlowLayout(spacing: 8) {
            if selectedEmotions.isEmpty {
                Text("No emotions")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
            } else {
                ForEach(selectedEmotions) { emotion in
                    Text(emotion.name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(color(for: emotion.group))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(color(for: emotion.group).opacity(0.12))
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func emotion(for id: UUID) -> Emotion? {
        emotions.first { $0.id == id }
    }

    private func color(for group: EmotionGroup?) -> Color {
        guard let color = group.flatMap({ color(from: $0.color) }) else {
            return .accentColor
        }

        return color
    }

    private func color(from hex: String) -> Color? {
        let sanitizedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        guard sanitizedHex.count == 6, let value = Int(sanitizedHex, radix: 16) else {
            return nil
        }

        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0

        return Color(red: red, green: green, blue: blue)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

private struct FlowLayout<Content: View>: View {
    let spacing: CGFloat
    let content: Content

    init(spacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 72), spacing: spacing)],
            alignment: .leading,
            spacing: spacing
        ) {
            content
        }
    }
}

#Preview {
    LogsView()
        .modelContainer(for: [
            EmotionGroup.self,
            Emotion.self,
            EmotionLog.self
        ], inMemory: true)
}
