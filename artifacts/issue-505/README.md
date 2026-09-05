# Issue 505 validation evidence

Issue: <https://github.com/callstack/react-native-bottom-tabs/issues/505>

## Environment

- `agent-device` 0.20.10
- Xcode 27.0 beta 4
- iPhone 17 Pro simulators on iOS 26.5 (`951CC10B-1B07-48EE-8636-59386FD2C58C`) and iOS 27.0 (`CD1ADD09-474F-4618-899B-689243327BC6`)
- Pixel 10 Pro emulator (`emulator-5554`)
- React Native 0.81.4 example app, New Architecture enabled

## iOS 26.5 reproduction

The baseline reproduction used a full-height `KeyboardAvoidingView` with a bottom-aligned `TextInput` and no manual tab-bar margin.

Before the fix, the input frame began at `y=803.67` while the native tab bar began at `y=791`. The accessibility snapshot marked the input as covered, and `agent-device press @e4` refused the unsafe tap. The baseline screenshot and recording are under `baseline/ios-26.5`.

After the final remediation, the input begins at `y=720.67` and ends at `y=770`, above the tab bar. A direct semantic tap succeeds. With the keyboard open, the input begins at `y=468.67`, remains hittable, and accepts `issue-505-remediated`. The remediated screenshots, recording, and launch log are under `verification/ios-26.5`.

The final example applies the measured tab-bar offset only to its `KeyboardAvoidingView`, inside a full-screen background view. Earlier target-state captures from a rejected broad scene-height adjustment are retained alongside the remediated captures for comparison.

## Scope checks

The example offset is restricted to iPhone on iOS 26 and later. The library's scene dimensions remain unchanged, preserving full-bleed and translucent backgrounds, scroll-edge behavior, existing `useBottomTabBarHeight` offsets, iPad/sidebar/tvOS layouts, minimized and accessory bars, custom or hidden bars, older iOS, and Android.

The remediated app build was also installed on iOS 27.0. The input again begins at `y=720.67`, and a direct selector-based tap succeeds. The remediated screenshot and launch log are under `verification/ios-27.0`.

Android was also exercised on the Pixel emulator. Its separate behavior—BottomNavigationView rising above the IME—reproduces and is already addressed by open PR #549, so this branch does not duplicate that Android change. Android screenshots are under `baseline/android`.

Two native-only experiments were rejected: moving SwiftUI measurement into each tab scene and respecting the container bottom safe area. Neither changed the explicit React Native scene height; their screenshots are retained under `rejected-native-candidates`.

Android video capture was attempted through `agent-device`, but a pre-existing device recovery manifest prevented recording. The two command diagnostics are retained under `baseline/android/logs`; screenshots still capture both rest and keyboard-open states.
