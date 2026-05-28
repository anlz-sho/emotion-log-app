import Foundation
import SwiftData
import SwiftUI

struct CalendarView: View {
    @Query(sort: \EmotionLog.date, order: .reverse) private var emotionLogs: [EmotionLog]
    @Query private var emotions: [Emotion]

    @State private var displayedMonth = Date()
    @State private var selectedDate = Date()

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    monthHeader
                    weekdayHeader
                    calendarGrid
                    selectedDateDetail
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .navigationTitle("Calendar")
        }
    }

    private var monthHeader: some View {
        HStack {
            Button {
                moveMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)

            Spacer()

            VStack(spacing: 4) {
                Text(Self.monthFormatter.string(from: displayedMonth))
                    .font(.title3.weight(.semibold))

                Text("Tap a date to review the log.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                moveMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.bordered)
        }
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: weekdayColumns, spacing: 8) {
            ForEach(Self.weekdaySymbols, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: weekdayColumns, spacing: 8) {
            ForEach(Array(monthDates.enumerated()), id: \.offset) { item in
                if let date = item.element {
                    dayButton(for: date)
                } else {
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
    }

    private var selectedDateDetail: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(Self.detailDateFormatter.string(from: selectedDate))
                .font(.headline)

            if let log = log(for: selectedDate) {
                emotionChips(for: log)

                if !log.memo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(log.memo)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text("No emotion log for this date.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
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

    private func dayButton(for date: Date) -> some View {
        let log = log(for: date)
        let emotionCount = log?.selectedEmotionIds.count ?? 0
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)

        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline.weight(isToday ? .bold : .semibold))

                if emotionCount > 0 {
                    Text("\(emotionCount)")
                        .font(.caption2.weight(.bold))
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .foregroundStyle(emotionCount > 0 ? .white : .primary)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(dayBackground(emotionCount: emotionCount, isSelected: isSelected))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(dayBorderColor(isToday: isToday, isSelected: isSelected), lineWidth: isToday || isSelected ? 2 : 0.5)
            }
        }
        .buttonStyle(.plain)
    }

    private func emotionChips(for log: EmotionLog) -> some View {
        let selectedEmotions = log.selectedEmotionIds.compactMap { emotion(for: $0) }

        return LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 72), spacing: 8)],
            alignment: .leading,
            spacing: 8
        ) {
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

    private var monthDates: [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let daysRange = calendar.range(of: .day, in: .month, for: displayedMonth)
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingBlankCount = firstWeekday - calendar.firstWeekday
        let normalizedLeadingBlankCount = leadingBlankCount >= 0 ? leadingBlankCount : leadingBlankCount + 7
        let leadingBlanks = Array<Date?>(repeating: nil, count: normalizedLeadingBlankCount)

        let days = daysRange.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)
        }

        return leadingBlanks + days
    }

    private var weekdayColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    }

    private func moveMonth(by value: Int) {
        guard let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) else {
            return
        }

        displayedMonth = newMonth

        if let monthInterval = calendar.dateInterval(of: .month, for: newMonth),
           !monthInterval.contains(selectedDate) {
            selectedDate = monthInterval.start
        }
    }

    private func log(for date: Date) -> EmotionLog? {
        emotionLogs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }

    private func emotion(for id: UUID) -> Emotion? {
        emotions.first { $0.id == id }
    }

    private func dayBackground(emotionCount: Int, isSelected: Bool) -> Color {
        guard emotionCount > 0 else {
            return isSelected ? Color(.tertiarySystemFill) : Color(.secondarySystemBackground)
        }

        let opacity = min(0.25 + Double(emotionCount) * 0.12, 0.85)
        return Color.accentColor.opacity(opacity)
    }

    private func dayBorderColor(isToday: Bool, isSelected: Bool) -> Color {
        if isSelected {
            return .accentColor
        }

        if isToday {
            return .primary.opacity(0.45)
        }

        return Color(.separator)
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

    private static let weekdaySymbols = Calendar.current.shortStandaloneWeekdaySymbols

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    private static let detailDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
}

#Preview {
    CalendarView()
        .modelContainer(for: [
            EmotionGroup.self,
            Emotion.self,
            EmotionLog.self
        ], inMemory: true)
}
