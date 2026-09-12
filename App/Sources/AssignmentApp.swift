import SwiftUI

@main
struct AssignmentApp: App {
    @State private var root = CompositionRoot()

    var body: some Scene {
        WindowGroup {
            RootView(root: root)
        }
    }
}
