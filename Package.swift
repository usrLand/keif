// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftBlusherFlags = [
    "-I../blusher/.build/debug/Modules",
    "-L../blusher/.build/debug",
]

let package = Package(
    name: "keif",
    products: [
        // .library(
        //     name: "Krest6",
        //     targets: ["Krest6"]
        // ),
        .library(
            name: "KeifCoreAddons",
            type: .dynamic,
            targets: ["KCoreAddons"]
        ),
        .library(
            name: "KeifXMLGUI",
            type: .dynamic,
            targets: ["KXMLGUI"]
        ),
    ],
    targets: [
        .target(
            name: "Krest"
        ),
        //==========
        // Qt
        //==========
        .systemLibrary(
            name: "Qt",
            pkgConfig: "Qt6Core"
        ),
        .target(
            name: "KQt",
            dependencies: ["Qt"],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
                .interoperabilityMode(.Cxx)
            ]
        ),
        //===========
        // Ports
        //===========
        .target(
            name: "KCoreAddons",
            dependencies: ["KQt"],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
                .unsafeFlags(swiftBlusherFlags),
                .interoperabilityMode(.Cxx),
            ],
            linkerSettings: [
                .linkedLibrary("Blusher"),
            ]
        ),
        .target(
            name: "KConfig",
            dependencies: ["KQt"],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
                .unsafeFlags(swiftBlusherFlags),
                .interoperabilityMode(.Cxx),
            ],
            linkerSettings: [
                .linkedLibrary("Blusher"),
            ]
        ),
        .target(
            name: "KXMLGUI",
            dependencies: ["KQt", "KCoreAddons"],
            swiftSettings: [
                .unsafeFlags(["-enable-library-evolution"]),
                .unsafeFlags(swiftBlusherFlags),
                .interoperabilityMode(.Cxx),
            ],
            linkerSettings: [
                .linkedLibrary("Blusher"),
            ]
        ),
        //===========
        // Tests
        //===========
        .testTarget(
            name: "KrestTests",
            dependencies: ["Krest", "Qt", "KCoreAddons"],
            swiftSettings: [
                .unsafeFlags([
                    "-I../blusher/.build/debug/Modules",
                    "-L../blusher/.build/debug",
                    "-lBlusher",
                ]),
                .interoperabilityMode(.Cxx)
            ]
        ),
    ]
)
