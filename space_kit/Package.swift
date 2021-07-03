// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SpaceKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "SpaceKit", targets: ["SpaceKit", "lib_spacekit"]),
    ],
    targets: [
        .target(name: "SpaceKit", dependencies: []),
        .binaryTarget(name: "lib_spacekit", path: "libspace_kit.xcframework"),
        .testTarget(name: "SpaceKitTests", dependencies: ["SpaceKit"]),
    ]
)
