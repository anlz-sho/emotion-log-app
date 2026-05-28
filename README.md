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

## Task 2

今日の感情入力画面を追加しました。

- Home 画面で感情グループごとに感情ボタンを表示
- 感情ボタンの複数選択
- 選択中ボタンの背景色変更
- メモ入力
- Save ボタンで `EmotionLog` を SwiftData に保存
- 初回起動時のデフォルト感情グループ / 感情データ作成

### Mac/Xcodeでビルド確認する手順

Task 2 のビルド確認は、あとで MacBook + Xcode で実施してください。

1. MacBook でこのリポジトリを pull する
2. `EmotionLogApp.xcodeproj` を Xcode で開く
3. iOS 17 以上の Simulator を選択する
4. `EmotionLogApp` scheme を選択して Run する
5. Home 画面に Positive / Neutral / Negative の感情グループが表示されることを確認する
6. 複数の感情ボタンを選択でき、選択中のボタン色が変わることを確認する
7. メモを入力して Save できることを確認する

## Task 2_1

感情ログの保存仕様と削除仕様を追加しました。

- 同じ日に複数回保存しても新しい `EmotionLog` は作成しない
- 今日の既存 `EmotionLog` がある場合は、選択した感情IDだけを追加する
- 既存の `selectedEmotionIds` は削除・上書きしない
- 重複する感情IDは追加しない
- メモは時刻付きで既存メモの末尾に追記する
- 今日の記録がある場合だけ Home 画面に削除ボタンを表示する
- 削除前に確認ダイアログを表示する

### Mac/Xcodeでビルド確認する手順

Task 2_1 のビルド確認は、あとで MacBook + Xcode で実施してください。

1. MacBook でこのリポジトリを pull する
2. `EmotionLogApp.xcodeproj` を Xcode で開く
3. iOS 17 以上の Simulator を選択する
4. 1回目の保存後、Home 画面に `Delete Today's Log` が表示されることを確認する
5. 同じ日に2回目以降の保存をしても、今日の `EmotionLog` が1件のまま追記されることを確認する
6. 同じ感情を再度保存しても `selectedEmotionIds` に重複追加されないことを確認する
7. メモが `[HH:mm]` 付きで末尾に追記されることを確認する
8. `Delete Today's Log` を押すと確認ダイアログが表示され、確認後に今日の記録が削除されることを確認する

## Task 3

保存済み感情ログを一覧表示する Logs 画面を追加しました。

- TabView に Logs タブを追加
- 保存済み `EmotionLog` を新しい順で表示
- ログの日付と時刻を表示
- 選択した感情をチップ表示
- メモをカード内に表示
- 保存済みログがない場合は空状態を表示
- 縦スクロール可能なカード風 UI

### Mac/Xcodeでビルド確認する手順

Task 3 のビルド確認は、あとで MacBook + Xcode で実施してください。

1. MacBook でこのリポジトリを pull する
2. `EmotionLogApp.xcodeproj` を Xcode で開く
3. iOS 17 以上の Simulator を選択する
4. TabView に Logs タブが表示されることを確認する
5. Home で保存したログが Logs 画面に新しい順で表示されることを確認する
6. 各ログカードに日付、時刻、選択感情、メモが表示されることを確認する
7. ログが複数ある場合に縦スクロールできることを確認する

## Task 4

保存済み感情ログを月表示で振り返る Calendar 画面を追加しました。

- 既存の TabView 構成を維持
- 月表示カレンダーを表示
- 記録がある日を色付きで表示
- その日の感情数に応じて色の濃さを変更
- 今日の日付を枠線で分かりやすく表示
- 日付タップで、その日の感情ログ詳細を表示
- 選択感情とメモを詳細カード内に表示
- 前月 / 翌月の切り替え

### Mac/Xcodeでビルド確認する手順

Task 4 のビルド確認は、あとで MacBook + Xcode で実施してください。

1. MacBook でこのリポジトリを pull する
2. `EmotionLogApp.xcodeproj` を Xcode で開く
3. iOS 17 以上の Simulator を選択する
4. 既存の Home / Logs / Calendar / Ranking タブ構成が維持されていることを確認する
5. Calendar タブに月表示カレンダーが表示されることを確認する
6. Home で保存した日が Calendar 上で色付き表示されることを確認する
7. 感情数が多い日の色が濃くなることを確認する
8. 日付をタップすると、その日の選択感情とメモが表示されることを確認する

## Task 5

Ranking 画面に基本ランキングを追加しました。

- 感情ランキングを表示
- 感情グループ別ランキングを表示
- 押された回数が多い順に表示
- 回数を表示
- 感情グループ色を活用した行表示
- スクロール可能な Ranking 画面
- 既存の TabView 構成を維持

Task 6 の週別・月別・曜日別集計は未実装です。

### Mac/Xcodeでビルド確認する手順

Task 5 のビルド確認は、あとで MacBook + Xcode で実施してください。

1. MacBook でこのリポジトリを pull する
2. `EmotionLogApp.xcodeproj` を Xcode で開く
3. iOS 17 以上の Simulator を選択する
4. 既存の Home / Logs / Calendar / Ranking タブ構成が維持されていることを確認する
5. Home で複数の感情を保存する
6. Ranking タブに感情ランキングと感情グループ別ランキングが表示されることを確認する
7. 回数が多い順に並び、各行に回数が表示されることを確認する
8. 感情グループ色がランキング行に反映されることを確認する
