import SwiftUI

struct PlanetEllipseView: View {
    let ellipseSize: CGSize
    let planetSize: CGFloat
    let angle: Angle

    var body: some View {
        ZStack {
            // Orbit ring
            Ellipse()
                .stroke(Color.black, lineWidth: 1)
            // Planet
            Circle()
                .fill(Color.green)
                .frame(width: planetSize, height: planetSize)
                .offset(parametricPlanetOffset)

            Circle()
                .fill(Color.orange)
                .frame(width: planetSize - 4, height: planetSize - 4)
                .offset(angularPlanetOffset)
        }.frame(width: ellipseSize.width, height: ellipseSize.height)
            .padding(planetSize / 2.0 + 10)
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

    /// Calculate the position of the planet using the angle given as an offset from
    /// the center of the ellipse.
    private var parametricPlanetOffset: CGSize {
        let a = ellipseSize.width / 2.0
        let b = ellipseSize.height / 2.0
        let x = a * cos(angle.radians)
        let y = b * sin(angle.radians)
        return CGSize(width: x, height: y)
    }
}

struct PlanetEllipseView_Previews: PreviewProvider {
    static var previews: some View {
        PlanetEllipseView(
            ellipseSize: CGSize(width: 400, height: 200),
            planetSize: 30,
            angle: .degrees(180)
        ).previewLayout(.sizeThatFits)
            .previewDisplayName("Planet Ring View")
    }
}
