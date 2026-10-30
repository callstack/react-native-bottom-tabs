// swift-tools-version: 6.0

import PackageDescription

// The SVG image decoder uses private CoreSVG APIs. RN_BOTTOM_TABS_ENABLE_SVG controls it
// when SwiftPM resolves the package:
//   unset            -> enabled, with a deprecation notice in dev builds
//   1 / true / yes   -> enabled
//   0 / false / no   -> disabled, no private CoreSVG code is compiled
let svgRawSetting = Context.environment["RN_BOTTOM_TABS_ENABLE_SVG"] ?? ""
let svgSetting = String(
    svgRawSetting.drop(while: \.isWhitespace).reversed().drop(while: \.isWhitespace).reversed()
).lowercased()
let svgSettingIsUnset = svgSetting.isEmpty
// TODO(next major): disable SVG when RN_BOTTOM_TABS_ENABLE_SVG is unset.
let enableSVG: Bool
switch svgSetting {
case "", "1", "true", "yes":
    enableSVG = true
case "0", "false", "no":
    enableSVG = false
default:
    fatalError(
        "[react-native-bottom-tabs] Unsupported value \"\(svgRawSetting)\" for RN_BOTTOM_TABS_ENABLE_SVG. "
            + "Use true or false (or 1 or 0)."
    )
}
// CSetting and CXXSetting are different types, so both lists map these names.
let svgDefines = [
    ("RN_BOTTOM_TABS_ENABLE_SVG", enableSVG),
    ("RN_BOTTOM_TABS_SVG_DEFAULTED", enableSVG && svgSettingIsUnset),
].filter(\.1).map(\.0)

let reactHeaders: [Target.Dependency] = [
    .product(name: "ReactHeaders", package: "ReactNative"),
    .product(name: "ReactNativeHeaders", package: "ReactNative"),
    .product(name: "ReactNativeDependenciesHeaders", package: "ReactNative"),
]

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
            ],
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
            ]
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
                "ios/SVG",
                "common/cpp",
            ],
            publicHeadersPath: "ios/include",
            cSettings: svgDefines.map { .define($0, to: "1") },
            cxxSettings: svgDefines.map { .define($0, to: "1") } + [
                .headerSearchPath("common/cpp"),
                .define("RCT_NEW_ARCH_ENABLED", to: "1"),
                // Fabric's C++ layout must match the selected React framework.
                .define("DEBUG", .when(configuration: .debug)),
                .define("NDEBUG", .when(configuration: .release)),
            ]
        ),
    ],
    swiftLanguageModes: [.v5],
    cxxLanguageStandard: .cxx20
)
