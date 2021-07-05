import SwiftUI

struct PlanetRingView: View {
    let planetSize: CGFloat
    let orbitRadius: CGFloat

    var body: some View {
        ZStack {
            // Orbit ring
            Circle()
                .stroke(Color.black, lineWidth: 1)
                .padding(planetSize / 2.0)
            // Planet
            Circle()
                .fill(Color.green)
                .frame(width: planetSize, height: planetSize)
                .offset(CGSize(width: orbitRadius, height: 0))
        }.frame(width: viewSize, height: viewSize)
    }

    // MARK: - Helpers

    private var viewSize: CGFloat {
        orbitRadius * 2 + planetSize
    }
}

struct PlanetRingView_Previews: PreviewProvider {
    static var previews: some View {
        PlanetRingView(planetSize: 44, orbitRadius: 100)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Planet Ring View")
    }
}
