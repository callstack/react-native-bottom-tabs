# Issue #532: iOS scroll-edge appearance evidence

## Expected behavior

The public API defines three values for `scrollEdgeAppearance`:

- `transparent`: when the bottom edge of an observable scroll view reaches the tab bar, the bar has no opaque background or separator and content remains visible beneath the system tab-bar material.
- `opaque`: the tab bar uses a theme-appropriate opaque background. A supplied `barTintColor` replaces the theme background.
- `default` or unconfigured: UIKit retains its platform-default appearance.

The transparent and opaque example screens use the same tabs and article content. At matching scroll positions, the opaque example must have a solid system background behind the complete tab bar, while the transparent example must retain the floating Liquid Glass presentation.

## Environment

- Date: 2026-08-31
- App: repository `apps/example` workspace, React Native 0.81.4, New Architecture enabled
- Device: iPhone 17 Pro simulator (`CD1ADD09-474F-4618-899B-689243327BC6`)
- Runtime: iOS 27.0
- Xcode: 27.0 Beta 4 (`27A5228h`)
- agent-device: 0.20.10
- Metro: repository example bundle on port 8085

No iOS 26.x runtime is installed in the available environment. The requested reproduction range was iOS 26 or newer, so the iOS 27.0 runtime exercises the `#available(iOS 26.0, *)` implementation and satisfies that range. These captures must not be represented as exact iOS 26.x evidence; an iOS 26.x compatibility run remains optional follow-up evidence if that runtime becomes available.

## Reproduction

The installed example app was opened with the repository's Metro bundle. For both existing example routes, the Article tab was captured at `What is Lorem Ipsum?`, scrolled down three equivalent agent-device scroll units, and explicitly verified at `Where can I get some?` before the bottom capture.

Before the fix, `Four Tabs - Transparent scroll edge appearance` and `Four Tabs - Opaque scroll edge appearance` both rendered as the same floating Liquid Glass tab bar at both positions:

- [Transparent, top](baseline/screenshots/transparent-top.png)
- [Transparent, bottom](baseline/screenshots/transparent-bottom.png)
- [Opaque, top](baseline/screenshots/opaque-top.png)
- [Opaque, bottom](baseline/screenshots/opaque-bottom.png)
- [Transparent scroll recording](baseline/videos/transparent-scroll.mp4)
- [Opaque scroll recording](baseline/videos/opaque-scroll.mp4)

## Diagnosis and fix verification

Runtime inspection confirmed that the JavaScript prop reached native code and that UIKit held the expected `UITabBarAppearance` values: the opaque route had `systemBackgroundColor` with a visible background, and the transparent route had a hidden scroll-edge background. On iOS 26 and newer, the floating Liquid Glass tab bar does not render those appearance-object background states as an opaque backing surface. Setting the public `UITabBar.backgroundColor` does control that backing surface.

The fix therefore sets the tab bar's own background on iOS 26 and newer when the requested appearance is opaque, when `translucent={false}` already requires opacity, or when a `barTintColor` is supplied for a non-transparent appearance. It preserves the supplied dynamic `UIColor`; otherwise opaque configurations use dynamic `systemBackground`. Transparent always clears the backing, and default/unconfigured configurations without a custom color retain the platform default. The existing `UITabBarAppearance` configuration remains responsible for item styling, shadows, and pre-iOS-26 behavior.

After the fix, the opaque route has a solid theme background while transparent and default preserve the platform Liquid Glass appearance. All cases were recorded at the same top and bottom article positions:

- [Default, top](verification/screenshots/default-top.png)
- [Default, bottom](verification/screenshots/default-bottom.png)
- [Default scroll recording](verification/videos/default-scroll.mp4)
- [Transparent, top](verification/screenshots/transparent-top.png)
- [Transparent, bottom](verification/screenshots/transparent-bottom.png)
- [Transparent scroll recording](verification/videos/transparent-scroll.mp4)
- [Opaque, top](verification/screenshots/opaque-top.png)
- [Opaque, bottom](verification/screenshots/opaque-bottom.png)
- [Opaque scroll recording](verification/videos/opaque-scroll.mp4)

The top/bottom screenshots above were refreshed from the final remediated binary on 2026-09-03. Additional compatibility evidence from the same simulator covers the adversarial-review findings:

- [Custom background, top](verification/compatibility/custom-background-top.png) and [bottom](verification/compatibility/custom-background-bottom.png)
- Opaque minimize behavior: [expanded](verification/compatibility/opaque-minimize-expanded.png), [collapsed](verification/compatibility/opaque-minimize-collapsed.png), and [restored](verification/compatibility/opaque-minimize-restored.png)
- Opaque hide/show: [shown](verification/compatibility/opaque-hide-shown.png), [hidden](verification/compatibility/opaque-hide-hidden.png), and [restored](verification/compatibility/opaque-hide-restored.png)
- Dynamic appearance: [dark](verification/compatibility/opaque-dark.png) and [light restored](verification/compatibility/opaque-light-restored.png)
- [`translucent={false}`](verification/compatibility/translucent-false.png)
- [Custom tab bar](verification/compatibility/custom-tabbar.png)

## Validation

- iOS simulator build: Xcode 27.0, iOS 27.0 SDK, deployment target iOS 15.1 — passed
- `yarn lint` — passed with three pre-existing warnings and no errors
- `yarn typecheck` — passed
- `yarn build` — passed
- `RCT_NEW_ARCH_ENABLED=1 yarn build:ios` — passed
- `node ../../node_modules/jest/bin/jest.js src/__tests__/index.test.tsx --runInBand` from the core package — passed (the repository currently contains one todo test)
- `git diff --check` — passed
- Device workflow: open, interactive snapshot, navigate, capture top, record and scroll, explicitly verify bottom content, capture bottom, close — passed

The adversarial-review findings and the exact remaining runtime verification are recorded in [review/dispositions.md](review/dispositions.md). The successful Fable JSON is preserved unchanged at [review/fable-review.json](review/fable-review.json).
