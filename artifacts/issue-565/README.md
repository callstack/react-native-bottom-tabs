# Issue #565 verification

These artifacts were captured from the example app on an iPhone 17 Pro simulator running iOS 26.5. The native builds used Xcode 27.0, CocoaPods 1.17.0, React Native 0.81.4, and the new architecture. Device automation used `agent-device` 0.20.10.

## Default configuration

`pod install` ran without `RN_BOTTOM_TABS_ENABLE_SVG`. The generated Pods project contained no `ios/SVG` source references and React Native codegen generated an empty `imageDataDecoderClassNames` array. The built app, app dylib, and `libreact-native-bottom-tabs.a` contained none of these strings:

- `CoreSVGWrapper`
- `SvgDecoder`
- `CGSVGDocument`
- `_imageWithCGSVGDocument`
- the CoreSVG symbol-name base64 literals

`RCTTabViewComponentView` was present as a positive control. The app was then exercised with SF Symbol and ordinary PNG icons:

- [SF Symbols](default/sf-symbols.png)
- [Selected SF Symbol tab](default/sf-symbols-albums.png)
- [PNG icons](default/png-icons.png)
- [Non-SVG interaction recording](default/non-svg-icons.mp4)

## SVG opt-in configuration

`pod install` ran with `RN_BOTTOM_TABS_ENABLE_SVG=1`. The generated Pods project included exactly `CoreSVG.{h,mm}` and `SvgDecoder.{h,mm}` and set `RN_BOTTOM_TABS_ENABLE_SVG` for Objective-C++ and Swift compilation. React Native codegen still generated an empty `imageDataDecoderClassNames` array because the decoder is library-scoped.

The built static library exported `RNBottomTabsDecodeSVGData` and contained `CoreSVGWrapper`, `CGSVGDocument`, and the CoreSVG symbol-name base64 literals. Both local and remote SVG tab sources rendered, and tab selection was verified through accessibility state:

- [Local SVG icons](opt-in/local-svg-icons.png)
- [Remote SVG icons](opt-in/remote-svg-icons.png)
- [SVG interaction recording](opt-in/svg-icons.mp4)

The same podspec configuration checks also passed with React Native 0.71.19, 0.76.9, 0.79.7, 0.81.6, 0.84.1, and 0.87.1 under CocoaPods 1.17.0, for both default and opted-in evaluation.
