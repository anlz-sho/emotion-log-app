import Foundation
import SwiftData

@Model
final class EmotionLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var memo: String

    @Relationship
    var selectedEmotions: [Emotion]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        selectedEmotions: [Emotion] = [],
        memo: String = ""
    ) {
        self.id = id
        self.date = date
        self.selectedEmotions = selectedEmotions
        self.memo = memo
    }
}
