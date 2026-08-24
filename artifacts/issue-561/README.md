# Issue 561 device verification

Captured with `agent-device` 0.20.10 against the example app's **Native Bottom Tabs with original icons** screen.

- iOS: iPhone 17 Pro simulator, iOS 26.5. The Avatar tab uses `tabBarIconSize: 34`; neighboring image tabs retain the existing 27 pt default.
- Android: Pixel 10 Pro emulator, Android API 37 at 3x density. The final accessibility hierarchy measured the Avatar image at 102x102 px (34 dp) and the default Chat image at 72x72 px (24 dp).

Artifacts:

- `ios-tab-icon-size.png` and `ios-tab-icon-size-selected.png`
- `ios-tab-icon-size.mp4`
- `android-tab-icon-size.png`
- `android-tab-icon-size.mp4`
- `android-avatar-hierarchy.txt` and `android-default-hierarchy.txt`
- `*-gesture-telemetry.json`
