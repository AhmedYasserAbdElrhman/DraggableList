// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DraggableList",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DraggableList",
            targets: ["DraggableList"]
        ),
    ],
    targets: [
        .target(
            name: "DraggableList"
        ),
    ]
)
