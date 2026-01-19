import SwiftUI

@main
struct AdventureMissionControlApp: App {
    @State private var viewModel = AdventureViewModel()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
