import SpaceKit
import SwiftUI

final class SolarSystemViewModel: ObservableObject {
    private let sizeMultiplierForPlanet: [Planet: CGFloat]
    private var displayLink: CADisplayLink?
    private var timeIncrement: TimeInterval = 0.0

    @Published
    private(set) var currentDate = Date()

    init() {
        var currentMultipler = 1.0
        let minMultiplier = 0.1
        let allPlanets = Planet.allCases.reversed()
        let decrementAmount = (currentMultipler - minMultiplier) / Double(allPlanets.count)

        sizeMultiplierForPlanet = allPlanets.reduce(into: [:]) { result, planet in
            defer { currentMultipler -= decrementAmount }
            result[planet] = currentMultipler
        }
    }

    func startAdvancingTime(startDate: Date, increment: TimeInterval) {
        stopAdvancingTime()
        currentDate = startDate
        timeIncrement = increment

        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFired(_:)))
        displayLink?.add(to: .main, forMode: .default)
    }

    func stopAdvancingTime() {
        displayLink?.invalidate()
        displayLink = nil
    }

    func ellipseSizeMultiplier(for planet: Planet) -> CGFloat {
        sizeMultiplierForPlanet[planet] ?? 1.0
    }

    func angle(of planet: Planet) -> Angle {
        let position = PlanetPosition(planet: planet, date: currentDate)
        return .radians(position.longitude)
    }

    // MARK: - Helpers

    @objc
    private func displayLinkFired(_ displayLink: CADisplayLink) {
        currentDate.addTimeInterval(timeIncrement)
    }
}
