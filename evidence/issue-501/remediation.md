# Issue #501 remediation

## Finding dispositions

1. **Resolved — recycled Fabric view identity.** `FocusRestoringView` now records the focused view's React tag and requires the current tag to match before returning that view from `preferredFocusEnvironments`. A recycled `UIView` whose tag has changed can no longer redirect focus to a different React element.

2. **Resolved — tvOS compile coverage.** The macOS CI job now invokes `swiftc` for an `arm64-apple-tvos15.1-simulator` target over `PlatformAliases.swift` and `RepresentableView.swift`. This directly compiles the `#if os(tvOS)` implementation at the library's declared tvOS deployment target without adding another example application or changing dependency versions.

3. **Resolved — release metadata.** `.changeset/fuzzy-tvs-focus.md` adds a patch changeset for `react-native-bottom-tabs`. The repository's fixed/dependent package rules propagate the release as shown by `yarn changeset status`.

4. **Resolved within the required evidence scope — evidence size, duplication, and repro verification.** The issue-specific directory is retained because the remediation requires the committed before/after recordings, useful screenshots, repro source, semantic snapshots, review JSON, and exact notes. The byte-identical `screenshots/issue-501-baseline-initial.png` was removed; its SHA-256 was the same as the retained and accurately named `screenshots/issue-501-baseline-after-return.png` (`054a9995b635dcc46e3d106640fb5f2e6505f7a16d673bf3f9a31d421276a913`). The reporter's `tvParallaxProperties` setting remains in the repro through a narrowly typed local wrapper because the repository typechecks against core React Native rather than the extended `react-native-tvos` declarations. `repro/tsconfig.json` makes the complete source independently typecheckable, and CI now typechecks and lints it. Both HEVC recordings, the three distinct screenshots, both semantic snapshots, the repro, the review, and the reproduction notes remain under `evidence/issue-501/`.

5. **Resolved — Swift brace style.** The multiline `if let` opening brace is now on the final condition line, matching the configured SwiftLint `opening_brace` rule.

6. **Unchanged — inapplicable to supported architectures.** The reported failure requires React Native's Paper architecture. This repository removed old-architecture support in commit `4b4e781cead514784c46599ab09554fad6c41208` (`feat!: drop old architecture`), recorded in `packages/react-native-bottom-tabs/CHANGELOG.md`. That commit deleted `RCTTabViewViewManager.mm`, removed the podspec's architecture conditional, and made New Architecture module installation unconditional. The current `RCTTabViewComponentView.mm` mounts and unmounts Fabric children through `insertChild` and `removeChildAtIndex`, which preserve the identities of unaffected children; it does not use `didUpdateReactSubviews`. Changing `IdentifiablePlatformView.id` for an unsupported Paper-only callback would therefore be a broader, unverified behavior change rather than a fix for a supported configuration.

## Validation performed

- `yarn lint` — passed with the three pre-existing warnings in `TabView.tsx` and `TabViewNativeComponent.ts` and no errors.
- `yarn typecheck` — passed.
- `yarn build` — passed.
- `yarn build:ios` — passed.
- `yarn build:android` — passed, including the New Architecture native build.
- `yarn tsc --project evidence/issue-501/repro/tsconfig.json` — passed.
- `yarn eslint evidence/issue-501/repro/App.tsx` — passed.
- `yarn prettier --check .github/workflows/ci.yml .changeset/fuzzy-tvs-focus.md evidence/issue-501/README.md evidence/issue-501/repro/App.tsx evidence/issue-501/repro/tsconfig.json` — passed.
- `ruby -e 'require "yaml"; YAML.load_file(".github/workflows/ci.yml")'` — passed.
- The standalone Hermes/Fabric repro rebuilt successfully with Xcode 26.6 (17F113), the tvOS 26.5 SDK, and a tvOS 15.1 deployment target after installing the final packed library.
- `xcrun --sdk appletvsimulator swiftc -module-cache-path /tmp/issue-501-swift-module-cache -target arm64-apple-tvos15.1-simulator -sdk "$(xcrun --sdk appletvsimulator --show-sdk-path)" -typecheck packages/react-native-bottom-tabs/ios/PlatformAliases.swift packages/react-native-bottom-tabs/ios/RepresentableView.swift` — passed with Xcode 26.6 and the tvOS 26.5 SDK while targeting tvOS 15.1.
- Equivalent `swiftc -typecheck` invocations passed for iOS 14.0 Simulator, macOS 11.0, and visionOS 1.0 Simulator targets.
- `yarn changeset status` — passed and reported patch bumps for `react-native-bottom-tabs` plus packages propagated by the repository's release configuration.
- `jq -e '.findings | length == 6 and all(.[]; has("file") and has("line") and has("defect") and has("failure_scenario") and has("severity"))' evidence/issue-501/review.json` — returned `true`.
- `git diff --check` — passed.
- `ffprobe` confirmed both retained videos are readable 1920×1080 HEVC recordings: baseline duration 19.67 seconds and final fixed duration 61.83 seconds. Contact-sheet inspection confirmed the baseline failure and final fixed focus sequences. `shasum -a 256` confirmed the removed screenshot was the sole duplicate among the screenshots.

SwiftLint is not installed in this sandbox, so its executable was not run locally. The post-remediation `agent-device` replay on tvOS 26.5 verified two `Button 8` sidebar round trips, the route-switch default of `Button 0`, and scrolled restoration to `Button 15`; it replaced the retained fixed recording and screenshot with evidence from the final code.
