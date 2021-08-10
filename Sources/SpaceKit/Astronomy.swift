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
        case noPhotoFound
        case invalidPhotoURLs
    }

    private let nasaAPIKey: String

    public init(nasaAPIKey: String) {
        self.nasaAPIKey = nasaAPIKey
    }

    @available(iOS 15.0, *)
    @MainActor
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

    // MARK: - Completion handler

    fileprivate func handleDidReceivePhoto(_ info: PhotoInfo?, completion: PhotoCompletion) {
        guard let info = info else {
            return completion(.failure(.noPhotoFound))
        }

        let title = String(cString: info.title)
        let explanation = String(cString: info.explanation)
        let urlString = String(cString: info.url)
        let hdURLString = String(cString: info.hd_url)
        guard let url = URL(string: urlString), let hdURL = URL(string: hdURLString) else {
            return completion(.failure(.invalidPhotoURLs))
        }

        let photo = Photo(title: title, explanation: explanation, url: url, hdURL: hdURL)
        completion(.success(photo))
    }
}

// MARK: - Callbacks

private func photoCallback(info: UnsafeMutablePointer<PhotoInfo>?, contextRawPointer: UnsafeMutableRawPointer?) {
    guard let contextRawPointer = contextRawPointer else { return }

    let contextPointer = contextRawPointer.bindMemory(to: AstronomyContext.self, capacity: 1)
    let context = contextPointer.pointee

    defer {
        contextPointer.deinitialize(count: 1)
        contextPointer.deallocate()
    }

    context.astronomy.handleDidReceivePhoto(info?.pointee, completion: context.completion)
}
