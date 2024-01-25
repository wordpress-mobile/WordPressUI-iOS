// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "WordPressUI",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "WordPressUI",
            targets: [
                "WordPressUIObjC",
                "WordPressUI",
            ]
        ),
        .library(
            name: "Gravatar",
            targets: ["Gravatar"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(name: "WordPressUIObjC"),
        .target(
            name: "WordPressUI",
            dependencies: [
                .target(name: "WordPressUIObjC"),
            ]
        ),
        .testTarget(
            name: "WordPressUITests",
            dependencies: [.target(name: "WordPressUI")]
        ),
        .target(
            name: "Gravatar",
            dependencies: ["WordPressUI"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "GravatarTests",
            dependencies: [.target(name: "Gravatar")]
        ),
    ]
)
