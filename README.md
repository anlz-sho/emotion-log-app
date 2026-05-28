# Emotion Log App

毎日の感情をボタンで記録し、カレンダーとランキングで振り返る iPhone アプリです。

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
- iOS 17+

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

### Mac/Xcodeでビルド確認する手順

現在の作業PCは Windows のため、この時点では SwiftUI プロジェクト構成とコードの作成までを行っています。
ビルド確認は、あとで MacBook + Xcode で実施してください。

1. MacBook でこのリポジトリを clone / pull する
2. `EmotionLogApp.xcodeproj` を Xcode で開く
3. iOS 17 以上の Simulator を選択する
4. `EmotionLogApp` scheme を選択して Run する
5. SwiftData の `ModelContainer` が起動時に作成されることを確認する
6. Home / Calendar / Ranking の TabView が表示されることを確認する
