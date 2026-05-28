import Foundation
import SwiftData

@Model
final class EmotionGroup {
    @Attribute(.unique) var id: UUID
    var name: String
    var color: String

    @Relationship(deleteRule: .cascade, inverse: \Emotion.group)
    var emotions: [Emotion]

    init(
        id: UUID = UUID(),
        name: String,
        color: String,
        emotions: [Emotion] = []
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.emotions = emotions
    }
}
