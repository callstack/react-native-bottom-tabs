# Issue #501 tvOS focus restoration evidence

## Environment

- macOS 26.6.2
- Xcode 26.6 (17F113), selected explicitly with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`
- Apple TV simulator, tvOS 26.5
- `agent-device` 0.20.10
- React 19.2.3
- `react-native-tvos` 0.83.1-0
- Hermes and the New Architecture enabled
- `react-native-bottom-tabs` and `@bottom-tabs/react-navigation` 1.4.0 built from this worktree
- `react-native-screens` 4.18.0 and `react-native-safe-area-context` 5.6.1

The standalone app was generated with:

```sh
npx --yes @react-native-community/cli@20.0.2 init TVFocusRepro --template @react-native-tvos/template-tv@0.83.0-0 --skip-install
```

Its screen implementation is preserved in [`repro/App.tsx`](repro/App.tsx). The Podfile used `platform :tvos`, and `RCT_NEW_ARCH_ENABLED=1 pod install` generated the native project. A test-harness-only post-install setting selected C++17 for the `fmt` pod because that version of the template otherwise fails to compile under Xcode 26.6; the library change does not alter C++ settings.

## Exact reproduction

1. Launch the app with the `Watching` route selected, `sidebarAdaptable` enabled, and `freezeOnBlur: true`.
2. Move Right from the selected sidebar tab into the list.
3. Move Down eight times so `Button 8` is focused.
4. Move Left to focus `Watching` in the expanded sidebar.
5. Move Right to close the sidebar and return to the list.

Before the fix, the semantic snapshots reported `Button 8` before opening the sidebar and `Button 0` after closing it. This matches the issue recording. See [`issue-501-baseline.mp4`](issue-501-baseline.mp4), [`baseline-focus.txt`](baseline-focus.txt), [`screenshots/issue-501-baseline-sidebar.png`](screenshots/issue-501-baseline-sidebar.png), and [`screenshots/issue-501-baseline-after-return.png`](screenshots/issue-501-baseline-after-return.png).

## Verification after the fix

- The same sequence returns focus to `Button 8`.
- Two additional Left/Right sidebar cycles continue to return to `Button 8`.
- After scrolling farther, a Left/Right cycle returns to `Button 15`, retaining the scroll position.
- A fresh install preserves the existing initial behavior: focus begins on the selected `Watching` sidebar tab, and Right enters the list at `Button 0` because no prior descendant exists.
- Switching from `Watching` to `Search` and back while `freezeOnBlur` is enabled uses the route's default `Button 0`; it does not target the stale `Button 5` from the previously active route.
- The app compiles for the repository's tvOS 15.1 deployment target with Xcode 26.6 and runs on tvOS 26.5 with Hermes and the New Architecture.
- iOS, macOS, visionOS, and Android behavior is unchanged because the focus-restoring wrapper is compiled only for tvOS.

See [`issue-501-fixed.mp4`](issue-501-fixed.mp4), [`fixed-focus.txt`](fixed-focus.txt), and [`screenshots/issue-501-fixed-button15.png`](screenshots/issue-501-fixed-button15.png).

## Repository checks

- `yarn lint` — passed with the repository's three existing warnings.
- `yarn typecheck` — passed.
- `yarn build` — passed.
- `yarn build:ios` — passed.
- `yarn build:android` — passed, including the New Architecture native build.
- `yarn tsc --project evidence/issue-501/repro/tsconfig.json` — passed.
- Standalone tvOS Xcode build — passed.
- `yarn test` — the repository command exits 1 before running tests because `@bottom-tabs/react-navigation` contains no tests. There is no native XCTest target in the library, so the focused regression is covered by the recorded simulator flow and semantic focus snapshots.
