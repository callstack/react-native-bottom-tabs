# Issue #560 device evidence

Captured on 2026-08-25 with `agent-device 0.20.10`, React Native 0.81.4,
Fabric enabled, Xcode 27.0 (27A5228h), and the repository example app
(`bottomtabs.example`).

## Before the fix

- Runtime: iOS 27.0, iPhone 17 Pro simulator.
- `before/unicode-tab-selection-crash.mp4` records tapping the `메시지` tab.
- `before/ReactTestApp-selection-crash.ips` records `SIGABRT` in
  `std::string(char const *)`, called by
  `-[RCTTabViewComponentView onPageSelectedWithKey:reactTag:]` at line 241.
- `before/unicode-tab-long-press-crash.mp4` records a long-press gesture on the
  same tab. The selection delegate aborts before the custom long-press callback
  can finish.
- `before/ReactTestApp-long-press-crash.ips` records the corresponding abort.

## After the fix

- Runtime: iOS 26.5, iPhone 17 Pro simulator (matching the issue's reported
  major runtime), plus an iOS 27.0 selection pass.
- `after/ios26-unicode-tab-selection-and-long-press.mp4` records successful
  selection and repeated long-press gestures without termination.
- `after/ios26-unicode-tab-selected.png` shows the selected Unicode tab and
  rendered Albums screen.
- `after/unicode-tab-selected.png` shows the corresponding iOS 27.0 selection
  pass.
- No new `ReactTestApp` crash report was generated during either post-fix run.
- `e2e-result/junit.xml` records the focused agent-device/Maestro regression
  flow passing (one test, zero failures). The corresponding interaction video,
  replay, and gesture telemetry are in the nested `attempt-1` directory.

The XCUITest synthesized hold used by `agent-device longpress` selected the tab
but did not trigger this example's custom `UILongPressGestureRecognizer`; the
same limitation reproduced on the existing ASCII `Article` tab. The focused
Maestro flow therefore asserts the original regression boundary: Unicode tap
and long-press gestures leave the app alive and the Unicode tab visible.
