import Foundation
import libspacekit

private struct AstronomyContext {
    let astronomy: Astronomy
    let completion: Astronomy.PhotoCompletion
}

public struct Photo: Equatable {
    public let title: String
    public let explanation: String
    public let url: URL
    public let hdURL: URL

    public init(
        title: String,
        explanation: String,
        url: URL,
        hdURL: URL
    ) {
        self.title = title
        self.explanation = explanation
        self.url = url
        self.hdURL = hdURL
    }
}

/// Utility for fetching the NASA astronomy photo of the day
public final class Astronomy {
    public typealias PhotoCompletion = (Result<Photo, Error>) -> Void

    public enum Error: Swift.Error {
        case fetchInProgress
        case noPhotoFound
        case invalidPhotoURLs
    }

    private let nasaAPIKey: String

    public init(nasaAPIKey: String) {
        self.nasaAPIKey = nasaAPIKey
    }

    @available(iOS 15.0, *)
    public func fetchPhoto() async throws -> Photo {
        try await withCheckedThrowingContinuation { continuation in
            fetchPhoto { result in
                switch result {
                case .success(let photo):
                    continuation.resume(returning: photo)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func fetchPhoto(with completion: @escaping PhotoCompletion) {
        let context = AstronomyContext(
            astronomy: self,
            completion: completion
        )

        let contextPointer = UnsafeMutablePointer<AstronomyContext>.allocate(capacity: 1)
        contextPointer.initialize(to: context)

        nasaAPIKey.withCString { pointer in
            fetch_photo_of_the_day(
                pointer,
                photoCallback,
                UnsafeMutableRawPointer(contextPointer)
            )
        }
    }

    fileprivate func handleDidReceivePhoto(_ photo: Photo, completion: PhotoCompletion) {
        completion(.success(photo))
    }

    fileprivate func handleError(_ error: Error, completion: PhotoCompletion) {
        completion(.failure(error))
    }
}

// MARK: - Callbacks

private func photoCallback(info: UnsafeMutablePointer<PhotoInfo>?, contextRawPointer: UnsafeMutableRawPointer?) {
    guard let contextRawPointer = contextRawPointer else { return }

    let contextPointer = contextRawPointer.assumingMemoryBound(to: AstronomyContext.self)
    let context = contextPointer.pointee
    let astronomy = context.astronomy
    let completion = context.completion

    defer {
        contextPointer.deinitialize(count: 1)
        contextPointer.deallocate()
    }

    guard let info = info else {
        return astronomy.handleError(.noPhotoFound, completion: completion)
    }

    let title = String(cString: info.pointee.title)
    let explanation = String(cString: info.pointee.explanation)
    let urlString = String(cString: info.pointee.url)
    let hdURLString = String(cString: info.pointee.hd_url)
    guard let url = URL(string: urlString), let hdURL = URL(string: hdURLString) else {
        return astronomy.handleError(.invalidPhotoURLs, completion: completion)
    }

    let photo = Photo(title: title, explanation: explanation, url: url, hdURL: hdURL)
    astronomy.handleDidReceivePhoto(photo, completion: completion)
}
