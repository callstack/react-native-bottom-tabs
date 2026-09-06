Remediated the valid Fable findings with a consumer-scoped fix instead of changing global scene layout.

### Findings

- Fixed — iPadOS/tvOS wrong-edge subtraction: removed `getSceneDimensions` entirely and restored the original full-size scene behavior.
- Fixed — full-bleed/translucent regressions and doubled offsets: `TabView.tsx` is back to its unmodified baseline; existing `useBottomTabBarHeight` usage remains unchanged.
- Fixed — `minimizeBehavior` dead strip: no scene height is reserved globally. Documentation explicitly excludes minimized bars from the fixed-content pattern.
- Fixed — bottom-accessory overlap: removed the incomplete global adjustment and scoped the documented workaround to layouts without bottom accessories.
- Rejected — binary evidence should be removed/gitignored: the user explicitly required durable device evidence. The retained evidence is catalogued in its [README](/Users/thiagobrez/.codex/worktrees/4916/react-native-bottom-tabs/artifacts/issue-505/README.md:13).
- Deferred — none.

### Changes

- Kept the reproducible [KeyboardAvoidingView example](/Users/thiagobrez/.codex/worktrees/4916/react-native-bottom-tabs/apps/example/src/Examples/KeyboardAvoidingView.tsx:14).
- Applied `useBottomTabBarHeight` only to the affected keyboard-avoiding content on iPhone/iOS 26+, while an outer view preserves the full-bleed background.
- Registered the example in [App.tsx](/Users/thiagobrez/.codex/worktrees/4916/react-native-bottom-tabs/apps/example/src/App.tsx:200).
- Added focused usage and scope documentation in [handling-scrollview-insets.md](/Users/thiagobrez/.codex/worktrees/4916/react-native-bottom-tabs/docs/docs/docs/guides/handling-scrollview-insets.md:11).
- Removed the proposed helper, invalid scene-resizing tests, and inaccurate changeset.
- Made no Android changes, avoiding duplication of PR #549.

### Verification

Passed:

- Focused ESLint: zero errors; two pre-existing warnings.
- `react-native-bottom-tabs` TypeScript build.
- iOS example Metro bundle.
- Documentation production build.
- Prettier check.
- `git diff --check`.

Existing infrastructure blockers:

- Example-wide TypeScript reports the pre-existing `LabeledTabs/showLabels` component-union error in `App.tsx`.
- Jest first encountered sandboxed Watchman permissions, then a pre-existing Babel parse failure in React Native’s Jest setup when rerun with Watchman disabled. No applicable runtime unit logic remains after removing the invalid scene-sizing helper.
