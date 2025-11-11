import SwiftUI
import SPAvatarKit

@main
struct AvatarKitDemoApp: App {
    init() {
        SPAvatarSDK.shared.setUpEnvironment(.develop)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
