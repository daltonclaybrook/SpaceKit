import Foundation

struct NASAAPIKey {
    private static let keyName = "NASA_API_KEY"

    static var apiKey: String {
        return _apiKey!
    }

    private static var _apiKey: String? {
        Bundle.main.infoDictionary?[keyName] as? String
    }

    static func assertKeyIsSet() {
        if _apiKey == nil {
            fatalError("The Info.plist does not contain the key: `NASA_API_KEY`")
        }
    }
}
