import Foundation
import SwiftData

@Model
final class EmotionLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var memo: String
    var selectedEmotionIds: [UUID]

    init(
        id: UUID = UUID(),
        date: Date = .now,
        selectedEmotionIds: [UUID] = [],
        memo: String = ""
    ) {
        self.id = id
        self.date = date
        self.selectedEmotionIds = selectedEmotionIds
        self.memo = memo
    }
}
