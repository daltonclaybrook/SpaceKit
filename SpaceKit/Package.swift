// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SpaceKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "SpaceKit", targets: ["SpaceKit", "libspacekit"]),
    ],
    targets: [
        .target(name: "SpaceKit", dependencies: []),
        .binaryTarget(name: "libspacekit", path: "libspacekit.xcframework"),
        .testTarget(name: "SpaceKitTests", dependencies: ["SpaceKit"]),
    ]
)
