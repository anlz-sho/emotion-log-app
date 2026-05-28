import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "heart.text.square")
                }

            LogsView()
                .tabItem {
                    Label("Logs", systemImage: "list.bullet.rectangle")
                }

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            RankingView()
                .tabItem {
                    Label("Ranking", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            EmotionGroup.self,
            Emotion.self,
            EmotionLog.self
        ], inMemory: true)
}
