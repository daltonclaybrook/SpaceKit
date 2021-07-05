import SwiftUI

final class HostingController: UIHostingController<ContentView> {
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
