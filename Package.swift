// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GeoFencingSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GeoFencingSDK",
            targets: ["GeoFencingSDK"]
        )
    ],
    targets: [
        .target(
            name: "GeoFencingSDK",
            dependencies: []
        ),
        .testTarget(
            name: "GeoFencingSDKTests",
            dependencies: ["GeoFencingSDK"]
        )
    ]
)


