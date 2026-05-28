import Foundation
import SwiftData

@Model
final class Emotion {
    @Attribute(.unique) var id: UUID
    var name: String
    var groupId: UUID?

    var group: EmotionGroup?

    init(
        id: UUID = UUID(),
        name: String,
        group: EmotionGroup? = nil
    ) {
        self.id = id
        self.name = name
        self.groupId = group?.id
        self.group = group
    }
}
