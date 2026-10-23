// swift-tools-version: 6.0

import PackageDescription

// Apple-platform SVG tab icons use private CoreSVG APIs, so they are opt-in.
// Set RN_BOTTOM_TABS_ENABLE_SVG=1 when SwiftPM resolves the package to enable them.
let enableSVG = Context.environment["RN_BOTTOM_TABS_ENABLE_SVG"] == "1"

let reactHeaders: [Target.Dependency] = [
    .product(name: "ReactHeaders", package: "ReactNative"),
    .product(name: "ReactNativeHeaders", package: "ReactNative"),
    .product(name: "ReactNativeDependenciesHeaders", package: "ReactNative"),
]

let svgTargets: [Target] = enableSVG ? [
    .target(
        name: "BottomTabsSVG",
        path: "ios/SVG",
        publicHeadersPath: "."
    ),
] : []

let package = Package(
    name: "react_native_bottom_tabs",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "react_native_bottom_tabs",
            targets: ["react_native_bottom_tabs"]
        ),
    ],
    dependencies: [
        // React Native references this package through
        // build/generated/autolinking/libs/react_native_bottom_tabs.
        // SwiftPM resolves these paths relative to that alias, including in monorepos.
        .package(name: "ReactNative", path: "../../../../xcframeworks"),
        .package(name: "React-GeneratedCode", path: "../../../ios"),
        .package(url: "https://github.com/siteline/swiftui-introspect.git", "1.0.0"..<"2.0.0"),
    ],
    targets: [
        .target(
            name: "BottomTabsSwift",
            dependencies: reactHeaders + [
                .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),
            ] + (enableSVG ? ["BottomTabsSVG"] : []),
            path: "ios",
            exclude: [
                "RCTTabViewComponentView.h",
                "RCTTabViewComponentView.mm",
                "RCTBottomAccessoryComponentView.h",
                "RCTBottomAccessoryComponentView.mm",
                "react-native-bottom-tabs-Bridging-Header.h",
                "SVG",
                "include",
                "Bridge",
            ],
            swiftSettings: enableSVG ? [.define("RN_BOTTOM_TABS_ENABLE_SVG")] : []
        ),
        .target(
            name: "BottomTabsBridge",
            dependencies: reactHeaders + ["BottomTabsSwift"],
            path: "ios/Bridge",
            publicHeadersPath: "."
        ),
        .target(
            name: "react_native_bottom_tabs",
            dependencies: reactHeaders + [
                "BottomTabsBridge",
                .product(name: "ReactAppHeaders", package: "React-GeneratedCode"),
            ],
            path: ".",
            exclude: ["node_modules", "android", "lib", "src"],
            sources: [
                "ios/RCTTabViewComponentView.mm",
                "ios/RCTBottomAccessoryComponentView.mm",
                "common/cpp",
            ],
            publicHeadersPath: "ios/include",
            cxxSettings: [
                .headerSearchPath("common/cpp"),
                .define("RCT_NEW_ARCH_ENABLED", to: "1"),
                // Fabric's C++ layout must match the selected React framework.
                .define("DEBUG", .when(configuration: .debug)),
                .define("NDEBUG", .when(configuration: .release)),
            ]
        ),
    ] + svgTargets,
    swiftLanguageModes: [.v5],
    cxxLanguageStandard: .cxx20
)
