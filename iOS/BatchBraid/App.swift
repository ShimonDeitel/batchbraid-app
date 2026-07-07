import SwiftUI

@main
struct BatchBraidApp: App {
    @StateObject private var store = BatchBraidStore()
    @StateObject private var purchases = PurchaseManager()
    @AppStorage("batchbraid_haptics_enabled") private var hapticsEnabled: Bool = true

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(store)
                .environmentObject(purchases)
                .preferredColorScheme(.light)
                .onAppear {
                    BBHaptics.enabled = hapticsEnabled
                }
        }
    }
}
