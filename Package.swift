// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SpaceKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "SpaceKit", targets: ["SpaceKit"]),
    ],
    targets: [
        .target(name: "SpaceKit", dependencies: ["libspacekit"]),
        .binaryTarget(
            name: "libspacekit",
            url: "https://github.com/daltonclaybrook/SpaceKit/releases/download/v0.1.1/libspacekit.xcframework.zip",
            checksum: "fa34c3792517c41cfbe695164a3c490671c9c028b2ef369a5ffcc2079e8a447b"
        ),
//        .binaryTarget(name: "libspacekit", path: "libspacekit.xcframework"),
        .testTarget(name: "SpaceKitTests", dependencies: ["SpaceKit"]),
    ]
)
