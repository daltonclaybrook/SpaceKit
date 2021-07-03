import libspace_kit
import Foundation

public struct Photo {
    public let title: String
    public let explanation: String
    public let url: URL
    public let hdURL: URL
}

public final class Coordinates {
    public init() {}

    public func printSomeCoordinates() {
        let day = julian_day_from_date(1989, 9, 25)
        let coordinates = heliocentric_coordinates(Mercury, day)
        print(coordinates)
    }

    public func fetchPhoto(nasaAPIKey: String) {
        nasaAPIKey.withCString { apiKey in
            fetch_photo_of_the_day(
                apiKey,
                photoCallback,
                Unmanaged.passUnretained(self).toOpaque()
            )
        }
    }

    // MARK: - Helpers

    fileprivate func handleDidReceivePhoto(_ photo: Photo) {
        print("Did receive photo: \(photo)")
    }

    fileprivate func handleError() {
        print("An error occurred...")
    }
}

// MARK: - Callbacks

private func photoCallback(info: UnsafeMutablePointer<PhotoInfo>?, context: UnsafeMutableRawPointer?) {
    guard let context = context else { return }

    let coordinates = Unmanaged<Coordinates>
        .fromOpaque(context)
        .takeUnretainedValue()

    guard let info = info else {
        print("Photo info was nil")
        return coordinates.handleError()
    }

    let title = String(cString: info.pointee.title)
    let explanation = String(cString: info.pointee.explanation)
    let urlString = String(cString: info.pointee.url)
    let hdURLString = String(cString: info.pointee.hd_url)
    guard let url = URL(string: urlString), let hdURL = URL(string: hdURLString) else {
        print("URLs are invalid")
        return coordinates.handleError()
    }

    let photo = Photo(title: title, explanation: explanation, url: url, hdURL: hdURL)
    coordinates.handleDidReceivePhoto(photo)
}
