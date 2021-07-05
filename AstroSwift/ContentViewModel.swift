import SpaceKit
import SwiftUI
import Foundation

final class ContentViewModel: ObservableObject {
    let astronomy = Astronomy(nasaAPIKey: NASAAPIKey.apiKey)

    @Published
    private(set) var angle: Angle = .degrees(0)
    @Published
    private(set) var ellipseHeightMultiplier: Double = 1.0

    private let angleIncrement: Double = 0.5
    private let heightIncrement: Double = 0.005
    private var heightSineArgument: Double = 0.0
    private var displayLink: CADisplayLink?

    init() {
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired(_:)))
    }

    func performSpaceKitTests() async {
        printPosition()
        await fetchPhoto()
    }

    func startIncrementingAngle() {
        displayLink?.add(to: .main, forMode: .default)
    }

    // MARK: - Helpers

    @objc
    private func displayLinkFired(_ displayLink: CADisplayLink) {
        let newAngle = (angle.degrees + angleIncrement).truncatingRemainder(dividingBy: 360.0)
        angle = .degrees(newAngle)

        heightSineArgument += heightIncrement
        // oscillates between 0.5 - 1.0
        ellipseHeightMultiplier = (sin(heightSineArgument) + 1) * 0.25 + 0.5
    }

    private func printPosition() {
        let components = DateComponents(year: 1989, month: 9, day: 25)
        guard let date = Calendar.current.date(from: components) else { return }
        let position = PlanetPosition(planet: .earth, date: date)
        print("position: \(position)")
    }

    private func fetchPhoto() async {
        do {
            let photo = try await astronomy.fetchPhoto()
            print("received photo: \(photo)")
        } catch let error {
            print("Received error: \(error)")
        }
    }
}
