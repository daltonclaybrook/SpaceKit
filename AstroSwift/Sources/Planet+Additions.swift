import SpaceKit
import SwiftUI

public extension Planet {
    var color: Color {
        switch self {
        case .mercury:
            return .gray
        case .venus:
            return .brown
        case .earth:
            return .blue
        case .mars:
            return .red
        case .jupiter:
            return .brown
        case .saturn:
            return .yellow
        case .uranus:
            return .green
        case .neptune:
            return .blue
        }
    }

    var imageName: String {
        switch self {
        case .mercury:
            return "Mercury"
        case .venus:
            return "Venus"
        case .earth:
            return "Earth"
        case .mars:
            return "Mars"
        case .jupiter:
            return "Jupiter"
        case .saturn:
            return "Saturn"
        case .uranus:
            return "Uranus"
        case .neptune:
            return "Neptune"
        }
    }
}
