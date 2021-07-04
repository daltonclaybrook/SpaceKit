import SpaceKit
import Foundation

final class ContentViewModel {
    let astronomy = Astronomy(nasaAPIKey: NASAAPIKey.apiKey)

    func performSpaceKitTests() async {
        printPosition()
        await fetchPhoto()
    }

    // MARK: - Helpers

    private func printPosition() {
        let components = DateComponents(year: 1989, month: 9, day: 25)
        guard let date = Calendar.current.date(from: components) else { return }
        let position = PlanetPositioning.getPosition(of: .earth, on: date)
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
