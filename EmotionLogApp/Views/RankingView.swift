import Foundation
import SwiftData
import SwiftUI

struct RankingView: View {
    @Query private var emotionLogs: [EmotionLog]
    @Query private var emotions: [Emotion]
    @Query private var emotionGroups: [EmotionGroup]

    @State private var aggregationUnit: AggregationUnit = .all
    @State private var selectedDate = Date()
    @State private var selectedWeekday = Calendar.current.component(.weekday, from: Date())

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            Group {
                if emotionLogs.isEmpty {
                    ContentUnavailableView(
                        "No Rankings",
                        systemImage: "chart.bar",
                        description: Text("Saved emotion logs will appear in rankings.")
                    )
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            aggregationControls

                            rankingSection(
                                title: "Emotion Ranking",
                                rows: emotionRankingRows,
                                emptyMessage: "No emotions have been recorded yet."
                            )

                            rankingSection(
                                title: "Group Ranking",
                                rows: groupRankingRows,
                                emptyMessage: "No emotion groups have been recorded yet."
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Ranking")
        }
    }

    private var aggregationControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Aggregation", selection: $aggregationUnit) {
                ForEach(AggregationUnit.allCases) { unit in
                    Text(unit.title).tag(unit)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Button {
                    moveAggregationBackward()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.bordered)
                .disabled(aggregationUnit == .all)

                VStack(alignment: .leading, spacing: 3) {
                    Text(aggregationTitle)
                        .font(.subheadline.weight(.semibold))

                    Text("\(filteredLogs.count) logs")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    moveAggregationForward()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.bordered)
                .disabled(aggregationUnit == .all)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
    }

    private func rankingSection(
        title: String,
        rows: [RankingRow],
        emptyMessage: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            if rows.isEmpty {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(rows.enumerated()), id: \.element.id) { item in
                        rankingRow(item.element, rank: item.offset + 1)
                    }
                }
            }
        }
    }

    private func rankingRow(_ row: RankingRow, rank: Int) -> some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(row.color)
                .frame(width: 28, height: 28)
                .background(row.color.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(row.name)
                    .font(.subheadline.weight(.semibold))

                GeometryReader { geometry in
                    Capsule()
                        .fill(row.color.opacity(0.18))
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(row.color.opacity(0.72))
                                .frame(width: barWidth(totalWidth: geometry.size.width, count: row.count))
                        }
                }
                .frame(height: 8)
            }

            Spacer(minLength: 8)

            Text("\(row.count)")
                .font(.subheadline.weight(.bold))
                .monospacedDigit()

            Text(row.count == 1 ? "time" : "times")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        }
    }

    private var emotionRankingRows: [RankingRow] {
        let counts = countEmotionIds()

        return emotions.compactMap { emotion in
            guard let count = counts[emotion.id], count > 0 else {
                return nil
            }

            return RankingRow(
                id: emotion.id,
                name: emotion.name,
                count: count,
                color: color(for: emotion.group)
            )
        }
        .sorted(by: rankingSort)
    }

    private var groupRankingRows: [RankingRow] {
        let emotionCounts = countEmotionIds()
        var groupCounts: [UUID: Int] = [:]

        for emotion in emotions {
            guard let group = emotion.group, let count = emotionCounts[emotion.id] else {
                continue
            }

            groupCounts[group.id, default: 0] += count
        }

        return emotionGroups.compactMap { group in
            guard let count = groupCounts[group.id], count > 0 else {
                return nil
            }

            return RankingRow(
                id: group.id,
                name: group.name,
                count: count,
                color: color(for: group)
            )
        }
        .sorted(by: rankingSort)
    }

    private var maxRankingCount: Int {
        max(
            emotionRankingRows.map(\.count).max() ?? 1,
            groupRankingRows.map(\.count).max() ?? 1
        )
    }

    private func countEmotionIds() -> [UUID: Int] {
        var counts: [UUID: Int] = [:]

        for log in filteredLogs {
            for emotionId in log.selectedEmotionIds {
                counts[emotionId, default: 0] += 1
            }
        }

        return counts
    }

    private func rankingSort(_ lhs: RankingRow, _ rhs: RankingRow) -> Bool {
        if lhs.count == rhs.count {
            return lhs.name < rhs.name
        }

        return lhs.count > rhs.count
    }

    private func barWidth(totalWidth: CGFloat, count: Int) -> CGFloat {
        guard maxRankingCount > 0 else {
            return 0
        }

        return totalWidth * CGFloat(count) / CGFloat(maxRankingCount)
    }

    private var filteredLogs: [EmotionLog] {
        switch aggregationUnit {
        case .all:
            return emotionLogs
        case .week:
            return emotionLogs.filter { calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .weekOfYear) }
        case .month:
            return emotionLogs.filter { calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .month) }
        case .weekday:
            return emotionLogs.filter { calendar.component(.weekday, from: $0.date) == selectedWeekday }
        }
    }

    private var aggregationTitle: String {
        switch aggregationUnit {
        case .all:
            return "All Logs"
        case .week:
            return "Week of \(Self.weekFormatter.string(from: selectedDate))"
        case .month:
            return Self.monthFormatter.string(from: selectedDate)
        case .weekday:
            return Self.weekdaySymbols[selectedWeekday - 1]
        }
    }

    private func moveAggregationBackward() {
        switch aggregationUnit {
        case .all:
            break
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        case .weekday:
            selectedWeekday = selectedWeekday == 1 ? 7 : selectedWeekday - 1
        }
    }

    private func moveAggregationForward() {
        switch aggregationUnit {
        case .all:
            break
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        case .weekday:
            selectedWeekday = selectedWeekday == 7 ? 1 : selectedWeekday + 1
        }
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
}

private enum AggregationUnit: String, CaseIterable, Identifiable {
    case all
    case week
    case month
    case weekday

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .week:
            return "Week"
        case .month:
            return "Month"
        case .weekday:
            return "Weekday"
        }
    }
}

private struct RankingRow: Identifiable {
    let id: UUID
    let name: String
    let count: Int
    let color: Color
}

private extension RankingView {
    static let weekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    static let weekdaySymbols = Calendar.current.weekdaySymbols
}

#Preview {
    RankingView()
        .modelContainer(for: [
            EmotionGroup.self,
            Emotion.self,
            EmotionLog.self
        ], inMemory: true)
}
