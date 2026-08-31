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

The fix therefore sets the tab bar's own background only when the requested appearance is opaque (or `translucent={false}` already requires opacity), using `barTintColor` when supplied and dynamic `systemBackground` otherwise. It clears that value for transparent/default configurations. The existing `UITabBarAppearance` configuration remains responsible for item styling, shadows, and pre-iOS-26 behavior.

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

## Validation

- iOS simulator build: Xcode 27.0, iOS 27.0 SDK, deployment target iOS 15.1 — passed
- `yarn lint` — passed with three pre-existing warnings and no errors
- `yarn typecheck` — passed
- `yarn build` — passed
- `RCT_NEW_ARCH_ENABLED=1 yarn build:ios` — passed
- `node ../../node_modules/jest/bin/jest.js src/__tests__/index.test.tsx --runInBand` from the core package — passed (the repository currently contains one todo test)
- `git diff --check` — passed
- Device workflow: open, interactive snapshot, navigate, capture top, record and scroll, explicitly verify bottom content, capture bottom, close — passed

The final automated checks and adversarial-review disposition are recorded alongside this evidence before the Draft PR is created.
