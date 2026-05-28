import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \EmotionGroup.name) private var emotionGroups: [EmotionGroup]

    @State private var selectedEmotionIds: Set<UUID> = []
    @State private var memo = ""
    @State private var showingSavedMessage = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    ForEach(emotionGroups) { group in
                        emotionSection(for: group)
                    }

                    memoSection
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("Home")
            .onAppear(perform: seedDefaultEmotionsIfNeeded)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Today's Emotion")
                .font(.title2.weight(.bold))

            Text("Select every feeling that fits today.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var memoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Memo")
                .font(.headline)

            TextEditor(text: $memo)
                .frame(minHeight: 120)
                .padding(10)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(.separator), lineWidth: 0.5)
                }
        }
    }

    private var saveButton: some View {
        Button(action: saveEmotionLog) {
            HStack {
                Image(systemName: "tray.and.arrow.down.fill")
                Text(showingSavedMessage ? "Saved" : "Save")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .disabled(selectedEmotionIds.isEmpty)
    }

    private func emotionSection(for group: EmotionGroup) -> some View {
        let emotions = group.emotions.sorted { $0.name < $1.name }

        return VStack(alignment: .leading, spacing: 12) {
            Text(group.name)
                .font(.headline)
                .foregroundStyle(color(for: group))

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 96), spacing: 12)],
                alignment: .leading,
                spacing: 12
            ) {
                ForEach(emotions) { emotion in
                    emotionButton(emotion, group: group)
                }
            }
        }
    }

    private func emotionButton(_ emotion: Emotion, group: EmotionGroup) -> some View {
        let isSelected = selectedEmotionIds.contains(emotion.id)
        let groupColor = color(for: group)

        return Button {
            toggleEmotion(emotion)
        } label: {
            Text(emotion.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(isSelected ? .white : groupColor)
                .background(isSelected ? groupColor : groupColor.opacity(0.12))
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(groupColor.opacity(isSelected ? 0 : 0.35), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func toggleEmotion(_ emotion: Emotion) {
        if selectedEmotionIds.contains(emotion.id) {
            selectedEmotionIds.remove(emotion.id)
        } else {
            selectedEmotionIds.insert(emotion.id)
        }

        showingSavedMessage = false
    }

    private func saveEmotionLog() {
        let log = EmotionLog(
            date: .now,
            selectedEmotionIds: Array(selectedEmotionIds),
            memo: memo.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        modelContext.insert(log)

        do {
            try modelContext.save()
            selectedEmotionIds.removeAll()
            memo = ""
            showingSavedMessage = true
        } catch {
            assertionFailure("Could not save emotion log: \(error)")
        }
    }

    private func seedDefaultEmotionsIfNeeded() {
        guard emotionGroups.isEmpty else { return }

        let defaultGroups: [(name: String, color: String, emotions: [String])] = [
            ("Positive", "#F97373", ["Happy", "Relaxed", "Grateful", "Excited"]),
            ("Neutral", "#60A5FA", ["Calm", "Tired", "Focused", "Unsure"]),
            ("Negative", "#8B5CF6", ["Sad", "Angry", "Anxious", "Lonely"])
        ]

        for defaultGroup in defaultGroups {
            let group = EmotionGroup(name: defaultGroup.name, color: defaultGroup.color)
            modelContext.insert(group)

            for emotionName in defaultGroup.emotions {
                let emotion = Emotion(name: emotionName, group: group)
                modelContext.insert(emotion)
            }
        }

        try? modelContext.save()
    }

    private func color(for group: EmotionGroup) -> Color {
        Color(hex: group.color) ?? .accentColor
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [
            EmotionGroup.self,
            Emotion.self,
            EmotionLog.self
        ], inMemory: true)
}

private extension Color {
    init?(hex: String) {
        let sanitizedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        guard sanitizedHex.count == 6, let value = Int(sanitizedHex, radix: 16) else {
            return nil
        }

        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }
}
