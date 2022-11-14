// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "WordPressUI",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "WordPressUI",
            targets: [
                "WordPressUIGravatar",
                "WordPressUIGravatarObjC",
                "WordPressUIObjCCategories",
                "WordPressUI",
            ]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "WordPressUIGravatar",
            path: "WordPressUI/Extensions/Gravatar",
            sources: ["Gravatar.swift"]
        ),
        .target(
            name: "WordPressUIGravatarObjC",
            path: "WordPressUI/Extensions/Gravatar",
            exclude: ["Gravatar.swift"],
            publicHeadersPath: "."
        ),
        .target(
            name: "WordPressUIObjCCategories",
            path: "WordPressUI/Categories",
            publicHeadersPath: "."
        ),
        .target(
            name: "WordPressUI",
            dependencies: [
                .target(name: "WordPressUIGravatar"),
                .target(name: "WordPressUIGravatarObjC"),
                .target(name: "WordPressUIObjCCategories"),
            ],
            path: "WordPressUI",
            exclude: [
                "WordPressUI.h",
                "Extensions/Gravatar",
                "Categories"
            ],
            resources: [
                .process("Resources"),
                .process("FancyAlert/FancyAlerts.storyboard")
            ]
        ),
        .testTarget(
            name: "WordPressUITests",
            dependencies: [.target(name: "WordPressUI")],
            path: "WordPressUITests",
            exclude: ["Info.plist"]
        ),
    ]
)
