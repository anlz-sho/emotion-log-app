import SwiftUI

struct RankingView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Ranking",
                systemImage: "chart.bar",
                description: Text("Emotion rankings will be implemented in Task 5.")
            )
            .navigationTitle("Ranking")
        }
    }
}

#Preview {
    RankingView()
}
