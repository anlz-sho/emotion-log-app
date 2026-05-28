import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "heart.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(.pink)

                Text("Emotion Log")
                    .font(.title2.weight(.semibold))

                Text("Today's emotion input screen will be implemented in Task 2.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
