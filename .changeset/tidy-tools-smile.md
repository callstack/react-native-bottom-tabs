---
"react-native-bottom-tabs": minor
---

Add the `$RNBottomTabsEnableSVG` Podfile flag, the `enableSVG` Expo plugin option, and the `RN_BOTTOM_TABS_ENABLE_SVG` environment variable for Swift Package Manager. Set the flag to `false` to remove the private CoreSVG code from Apple builds. When the flag is not set, SVG decoding stays enabled and `pod install` shows a deprecation warning. The next major version disables SVG decoding by default.
