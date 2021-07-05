import SpaceKit
import SwiftUI

private let ellipseViewPadding: CGFloat = 30.0

struct EllipseView: View {
    let ellipseSize: CGSize

    var body: some View {
        Ellipse()
            .stroke(Color.black, lineWidth: 1)
            .frame(width: ellipseSize.width, height: ellipseSize.height)
            .padding(ellipseViewPadding)
    }
}

struct PlanetView: View {
    let ellipseSize: CGSize
    let planet: Planet
    let angle: Angle

    var body: some View {
        Image(planet.imageName)
            .scaleEffect(0.4)
            .offset(angularPlanetOffset)
            .frame(width: ellipseSize.width, height: ellipseSize.height)
            .padding(ellipseViewPadding)
    }

    // MARK: - Helpers

    /// Calculate the position of the planet using the angle given as an offset from
    /// the center of the ellipse.
    private var angularPlanetOffset: CGSize {
        let a = ellipseSize.width / 2.0
        let b = ellipseSize.height / 2.0
        let xNumerator = a * b
        let yNumerator = a * b * tan(angle.radians)
        let denominator = sqrt(pow(b, 2.0) + pow(a, 2.0) * pow(tan(angle.radians), 2.0))
        let width = xNumerator / denominator
        let height = yNumerator / denominator

        if angle.degrees > 90 && angle.degrees <= 270 {
            return CGSize(width: -width, height: -height)
        } else {
            return CGSize(width: width, height: height)
        }
    }
}

struct PlanetEllipseView_Previews: PreviewProvider {
    static let ellipseSize = CGSize(width: 400, height: 200)

    static var previews: some View {
        ZStack {
            EllipseView(ellipseSize: ellipseSize)
            PlanetView(ellipseSize: ellipseSize, planet: .earth, angle: .degrees(270))
        }.previewLayout(.sizeThatFits)
            .previewDisplayName("Planet Ring View")
    }
}
