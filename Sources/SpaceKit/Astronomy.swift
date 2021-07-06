import Foundation
import libspacekit

public struct Photo {
    public let title: String
    public let explanation: String
    public let url: URL
    public let hdURL: URL
}

/// Utility for fetching the NASA astronomy photo of the day
public final class Astronomy {
    public enum Error: Swift.Error {
        case fetchInProgress
        case noPhotoFound
        case invalidPhotoURLs
    }

    private let nasaAPIKey: String
    private var completion: ((Result<Photo, Error>) -> Void)?

    public init(nasaAPIKey: String) {
        self.nasaAPIKey = nasaAPIKey
    }

    @available(iOS 15.0, *)
    public func fetchPhoto() async throws -> Photo {
        guard completion == nil else { throw Error.fetchInProgress }

        return try await withCheckedThrowingContinuation { continuation in
            completion = { result in
                switch result {
                case .success(let photo):
                    continuation.resume(returning: photo)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            _fetchPhoto()
        }
    }

    public func fetchPhoto(with completion: @escaping (Result<Photo, Error>) -> Void) {
        guard self.completion == nil else {
            return completion(.failure(.fetchInProgress))
        }
        self.completion = completion
        _fetchPhoto()
    }

    // MARK: - Helpers

    private func _fetchPhoto() {
        nasaAPIKey.withCString { pointer in
            fetch_photo_of_the_day(
                pointer,
                photoCallback,
                Unmanaged.passUnretained(self).toOpaque()
            )
        }
    }

    fileprivate func handleDidReceivePhoto(_ photo: Photo) {
        let completion = completion
        self.completion = nil
        completion?(.success(photo))
    }

    fileprivate func handleError(_ error: Error) {
        let completion = completion
        self.completion = nil
        completion?(.failure(error))
    }
}

// MARK: - Callbacks

private func photoCallback(info: UnsafeMutablePointer<PhotoInfo>?, context: UnsafeMutableRawPointer?) {
    guard let context = context else { return }

    let coordinates = Unmanaged<Astronomy>
        .fromOpaque(context)
        .takeUnretainedValue()

    guard let info = info else {
        return coordinates.handleError(.noPhotoFound)
    }

    let title = String(cString: info.pointee.title)
    let explanation = String(cString: info.pointee.explanation)
    let urlString = String(cString: info.pointee.url)
    let hdURLString = String(cString: info.pointee.hd_url)
    guard let url = URL(string: urlString), let hdURL = URL(string: hdURLString) else {
        return coordinates.handleError(.invalidPhotoURLs)
    }

    let photo = Photo(title: title, explanation: explanation, url: url, hdURL: hdURL)
    coordinates.handleDidReceivePhoto(photo)
}
