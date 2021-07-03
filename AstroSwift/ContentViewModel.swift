import SpaceKit

final class ContentViewModel {
    let coordinates = Coordinates()

    func performSpaceKitTests() {
        coordinates.printSomeCoordinates()
        coordinates.fetchPhoto(nasaAPIKey: NASAAPIKey.apiKey)
    }
}
