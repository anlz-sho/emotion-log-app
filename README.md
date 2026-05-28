# Emotion Log App

毎日の感情をボタンで記録し、カレンダーとランキングで振り返るiPhoneアプリ。

## MVP
- 感情ボタンを選択
- メモ入力
- 日時付きで保存
- 過去ログ閲覧
- カレンダー表示
- 感情ランキング

## Tech
- SwiftUI
- SwiftData
- iOS app

## Task 1

SwiftUI + SwiftData の基本プロジェクト構成を追加しました。

- `EmotionLogApp.xcodeproj`
- `EmotionLogApp/EmotionLogApp.swift`
- `EmotionLogApp/Models/EmotionGroup.swift`
- `EmotionLogApp/Models/Emotion.swift`
- `EmotionLogApp/Models/EmotionLog.swift`
- `EmotionLogApp/Views/ContentView.swift`
- `EmotionLogApp/Views/HomeView.swift`
- `EmotionLogApp/Views/CalendarView.swift`
- `EmotionLogApp/Views/RankingView.swift`

### Mac/Xcodeで確認

この作業環境は Windows のため、Xcode / xcodebuild によるビルド確認は未実施です。

Mac で以下を確認してください。

1. `EmotionLogApp.xcodeproj` を Xcode で開く
2. iOS 17 以上の Simulator を選択する
3. `EmotionLogApp` scheme を Run する
4. SwiftData の `ModelContainer` が起動時に作成されることを確認する
5. Home / Calendar / Ranking の TabView が表示されることを確認する
