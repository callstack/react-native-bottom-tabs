# Issue #507 reproduction evidence

Tested on 2026-09-04 with:

- React Native 0.84.1
- React 19.2.3
- Hermes enabled
- Android 15 (API 35), arm64 emulator
- Java 17
- agent-device 0.20.10

The reproduction project set `newArchEnabled=false` to match the report. React
Native 0.84.1 prints that this setting is unsupported since 0.82 and runs the
New Architecture regardless; the runtime log confirmed `fabric: true`.

## Result

The screenshot in the issue maps exactly to
`@react-navigation/bottom-tabs@8.0.0-alpha.19`'s generated
`BottomTabViewNativeImpl.js`: its `materialSymbol` branch starts at line 391 and
calls `MaterialSymbol.getImageSource` at line 396. This file belongs to the
React Navigation repository, not `react-native-bottom-tabs`.

The reported error reproduces when the alpha bottom-tabs package is forced to
use an incompatible stable native package:

```text
@react-navigation/bottom-tabs 8.0.0-alpha.19
@react-navigation/native      7.2.0
react-native-screens          4.24.0
```

`@react-navigation/bottom-tabs@8.0.0-alpha.19` declares
`@react-navigation/native@^8.0.0-alpha.16` as a peer dependency. Version 7.2.0
does not export `MaterialSymbol`, so the call fails with:

```text
TypeError: Cannot read property 'getImageSource' of undefined
```

Evidence:

- [`peer-mismatch-repro.mp4`](./peer-mismatch-repro.mp4)
- [`peer-mismatch-repro.png`](./peer-mismatch-repro.png)

After aligning the peer versions and rebuilding Android, the same tab options
render both the filled Home symbol and outlined Settings symbol:

```text
@react-navigation/bottom-tabs 8.0.0-alpha.19
@react-navigation/native      8.0.0-alpha.16
@react-navigation/elements    3.0.0-alpha.17
@react-navigation/core        8.0.0-alpha.8
react-native-screens          4.24.0
```

Evidence:

- [`aligned-react-navigation-peers.mp4`](./aligned-react-navigation-peers.mp4)
- [`aligned-react-navigation-peers.png`](./aligned-react-navigation-peers.png)
- [`aligned-tab-switch.mp4`](./aligned-tab-switch.mp4)
- [`aligned-settings-selected.png`](./aligned-settings-selected.png)

## Reproduction flow

1. Create a clean React Native 0.84.1 app.
2. Install `@react-navigation/bottom-tabs@8.0.0-alpha.19`,
   `@react-navigation/native@7.2.0`, and `react-native-screens@4.24.0` while
   overriding the peer-dependency error.
3. Use the `materialSymbol` `tabBarIcon` options from issue #507.
4. Build and launch Android.
5. Observe the `getImageSource` render error.
6. Install the matching alpha peer versions shown above and rebuild Android.
7. Launch the same code and verify both Material Symbols render and both tabs
   can be selected.

No source change in this repository is applicable: it neither implements nor
exports the `materialSymbol` API shown in the report.
