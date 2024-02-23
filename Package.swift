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
                "WordPressUI"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", from: "0.54.0")
    ],
    targets: [
        .target(name: "WordPressUIObjC"),
        .target(
            name: "WordPressUI",
            dependencies: [
                .target(name: "WordPressUIObjC")
            ],
            plugins: [
                 .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        ),
        .testTarget(
            name: "WordPressUITests",
            dependencies: [.target(name: "WordPressUI")],
            plugins: [
                 .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
            ]
        )
    ]
)
