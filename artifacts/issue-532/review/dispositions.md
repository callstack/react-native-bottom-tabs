# Issue #532 Fable review dispositions

This file records the single successful Claude Code Fable/High review and the single GPT-5.6-Sol/High remediation pass for the four findings in `fable-review.json`. The review JSON is intentionally unchanged, and Fable was not rerun after remediation.

## 1. Custom `barTintColor` with default/unconfigured scroll-edge appearance

**Fixed.** The finding was valid. On iOS 26 and newer, `updateTabBarAppearance` now gives a non-transparent configured `barTintColor` to the tab bar backing even when `scrollEdgeAppearance` is default or unset. The precedence is explicit:

| Configuration | iOS 26+ tab-bar backing |
| --- | --- |
| `scrollEdgeAppearance="transparent"` | cleared, including when a color was supplied |
| default/unconfigured plus `barTintColor` | supplied color |
| `scrollEdgeAppearance="opaque"` plus `barTintColor` | supplied color |
| `scrollEdgeAppearance="opaque"` without a color | dynamic `systemBackground` |
| `translucent={false}` without a color | dynamic `systemBackground` |
| default/unconfigured, translucent, no color | cleared so UIKit retains its default |

Repository evidence: `apps/example/src/App.tsx` exposes “Four Tabs - Custom Background Color of Tabs” with `#87CEEB`; `apps/example/src/Examples/FourTabs.tsx` maps that value to `tabBarStyle.backgroundColor`; `packages/react-native-bottom-tabs/src/TabView.tsx` maps it to native `barTintColor`; and `TabViewImpl.swift` now consumes it in the iOS 26+ backing path. Passing the existing `UIColor` object to `UIView.backgroundColor` preserves dynamic colors. The block is compiled only for iOS and runs only on iOS 26+, so pre-iOS-26 behavior and tvOS, visionOS, and macOS behavior remain unchanged. The standard appearance object continues to cover both normal and scroll-edge positions.

The final remediated binary was verified through the repository's custom-background example at equivalent top and bottom article positions. Both captures show the configured `#87CEEB` backing: [top](../verification/compatibility/custom-background-top.png) and [bottom](../verification/compatibility/custom-background-bottom.png).

## 2. Minimize, hide, and dark-mode interaction

**Concretely disproven.** The finding described a possible artifact but provided no reproduction or runtime evidence. The implementation uses the public inherited `UIView.backgroundColor` on the real `UITabBar`; it does not add an overlay, mask, appearance proxy, private API, delayed update, or independently positioned view. Existing hiding is also applied to the real system tab bar through SwiftUI's public `toolbar(.hidden, for: .tabBar)` path on supported OS versions. The remediation preserves dynamic `UIColor.systemBackground`, which is the theme-aware value needed for light/dark changes.

No speculative transition workaround was added because UIKit exposes no public minimized-state callback in the installed iOS 27 SDK, and changing or disabling the caller's `minimizeBehavior` would violate that public API.

The primary agent completed the real-app verification on the documented iPhone 17 Pro / iOS 27.0 simulator with the repository Metro bundle and the same public props. Temporary QA-only example wiring was removed before the final diff. The opaque minimize path collapses to the system-managed control without leaving a rectangular band and restores its full backing on scroll-up: [expanded](../verification/compatibility/opaque-minimize-expanded.png), [collapsed](../verification/compatibility/opaque-minimize-collapsed.png), and [restored](../verification/compatibility/opaque-minimize-restored.png).

Hide/show leaves no backing while hidden and restores cleanly: [shown](../verification/compatibility/opaque-hide-shown.png), [hidden](../verification/compatibility/opaque-hide-hidden.png), and [restored](../verification/compatibility/opaque-hide-restored.png). Dynamic `systemBackground` resolves to black in [dark appearance](../verification/compatibility/opaque-dark.png) and back to white after [restoring light appearance](../verification/compatibility/opaque-light-restored.png).

The final binary also rechecked default, transparent, and opaque at matching top/bottom positions; verified [`translucent={false}`](../verification/compatibility/translucent-false.png); and verified the repository's [custom tab-bar example](../verification/compatibility/custom-tabbar.png). The lifecycle captures were made immediately before the custom-color-only remediation was installed; that remediation does not alter the opaque condition or value exercised by those captures. The final installed binary then refreshed all default/transparent/opaque screenshots and captured the custom-color, `translucent={false}`, and custom-tab-bar cases.

## 3. Evidence captured on iOS 27 rather than iOS 26

**Concretely disproven as a requirements violation.** The explicit reproduction requirement is iOS 26 or newer, not exactly iOS 26.x. The captured device reports iOS 27.0, which is within that range and executes the `#available(iOS 26.0, *)` branch. The evidence README records the exact simulator, runtime, Xcode beta, and capture date; it does not label the captures as iOS 26.

The limitation is now explicit in the evidence README: no iOS 26.x runtime is installed, so the branch has no exact-26 capture and none is fabricated. If an iOS 26.x runtime later becomes available, a compatibility run may add confidence about version-specific compositing, but it was not part of the user's `>=26` acceptance requirement.

## 4. Checked-in binary evidence and missing disposition record

**Concretely disproven in part and fixed in part.** Repository-size preference cannot override the user's explicit requirement that clear issue-specific screenshots and videos be committed on this branch. All existing media is therefore preserved. The valid incompleteness portion is fixed by this disposition file, and the evidence README now links both this file and the unchanged successful Fable JSON instead of promising a future record.

## Remediation checks

- `yarn lint` — passed; the three reported warnings predate this remediation and are unrelated to issue #532.
- `yarn typecheck` — passed.
- `yarn build` — passed.
- `RCT_NEW_ARCH_ENABLED=1 yarn build:ios` — passed.
- Core Jest test (`src/__tests__/index.test.tsx`) — passed with the repository's one existing todo.
- The `react-native-bottom-tabs` CocoaPods scheme was built for the generic iOS device SDK with code signing disabled — passed, including compilation of `TabViewImpl.swift`.
- The complete example workspace was built for the iPhone 17 Pro / iOS 27.0 simulator with code signing disabled — passed.
- The final remediated app was installed and the default, transparent, opaque, custom-color, `translucent={false}`, and custom-tab-bar cases were explicitly verified. Minimize, hide/show, and light/dark lifecycle checks also passed as documented above.
- `git diff --check` — passed.
- `fable-review.json` parsed with all four findings and remained unchanged at SHA-256 `6a57310f6a0f8c9885ae6f3962e5ebbe6f7eb9e2d49b6d9308a93b08aac55942`.
