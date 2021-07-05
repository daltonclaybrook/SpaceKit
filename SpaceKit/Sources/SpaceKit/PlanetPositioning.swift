import libspacekit
import Foundation

/// The planets of our solar system
public enum Planet: CaseIterable {
    case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
}

public struct PlanetPosition {
    /// The planet that the position refers to
    public let planet: Planet
    /// Heliocentric longitude in radians
    public let longitude: Double
    /// Heliocentric latitude in radians
    public let latitude: Double
    /// Heliocentric radius vector in AU
    public let radiusVector: Double
}

public extension PlanetPosition {
    init(planet: Planet, date: Date) {
        let components = Self.calendar.dateComponents(Self.allComponents, from: date)
        let decimalDay = Self.getDecimalDay(from: components)
        let julianDay = julian_day_from_date(Int16(components.year!), UInt8(components.month!), decimalDay)
        let coordinates = heliocentric_coordinates(planet.libSpaceKitPlanet, julianDay)
        self.init(
            planet: planet,
            longitude: coordinates.longitude,
            latitude: coordinates.latitude,
            radiusVector: coordinates.radius_vector
        )
    }

    // MARK: - Helpers

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private static var allComponents: Set<Calendar.Component> {
        [.year, .month, .day, .hour, .minute, .second]
    }

    /// Return the day component plus a value 0.0 - 1.0 representing the fraction of the day derived
    /// from hour, minute, and second components.
    private static func getDecimalDay(from components: DateComponents) -> Double {
        guard let day = components.day,
              let hour = components.hour,
              let minute = components.minute,
              let second = components.second
        else { return 0.0 }

        let hourSeconds = Double(hour) * 60.0 * 60.0
        let minuteSeconds = Double(minute) * 60.0
        let totalSeconds = hourSeconds + minuteSeconds + Double(second)

        let secondsInDay = 24.0 * 60.0 * 60.0
        let dayFraction = totalSeconds / secondsInDay

        return Double(day) + dayFraction
    }
}

private extension Planet {
    var libSpaceKitPlanet: libspacekit.Planet {
        switch self {
        case .mercury:
            return Mercury
        case .venus:
            return Venus
        case .earth:
            return Earth
        case .mars:
            return Mars
        case .jupiter:
            return Jupiter
        case .saturn:
            return Saturn
        case .uranus:
            return Uranus
        case .neptune:
            return Neptune
        }
    }
}
