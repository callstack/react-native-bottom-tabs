# Issue #547 verification evidence

This directory records the reproduction and verification for the iOS 27 lazy-tab white flash.

## Environment

- Base commit: `1bbcaa2`
- Xcode: 27.0 (`27A5228h`)
- iOS 27 simulator runtime: 27.0 (`24A5390f`)
- iOS 27 device: iPhone 17 Pro (`CD1ADD09-474F-4618-899B-689243327BC6`)
- Compatibility runtime: iOS 26.5 (`23F77`)
- iOS 26 device: iPhone 17 Pro (`951CC10B-1B07-48EE-8636-59386FD2C58C`)
- Example app: React Native 0.81.4, Hermes, New Architecture
- `agent-device`: 0.20.10

## Reproduction

The current example app's **Native > Lazy Tabs** screen was launched with the navigator's default `lazy: true`. Starting on Article, Contacts was selected for the first time while recording at 50 fps. The native tab switched before React had mounted the lazy scene, producing a fully white content frame between the two screens.

- [`before/videos/first-lazy-contacts-review.mp4`](before/videos/first-lazy-contacts-review.mp4): three-second review clip
- [`before/screenshots/transition-contact-sheet.png`](before/screenshots/transition-contact-sheet.png): sampled transition frames
- [`before/screenshots/white-flash-frame.png`](before/screenshots/white-flash-frame.png): captured white frame
- [`before/logs/app.log`](before/logs/app.log): application log for the run

The untrimmed 50 fps capture and gesture telemetry are retained in `before/videos/`.

## Verification after the fix

The identical first activation was recorded at 75 fps. Article remains visible until the mounted Contacts scene is ready; no empty frame appears. A second run activates a lazy screen with a permanent `#1E2D2F` background, confirming that the implementation does not depend on masking the transition with the default color.

- [`after/videos/first-lazy-contacts.mp4`](after/videos/first-lazy-contacts.mp4): default appearance, 3.29 seconds at 75 fps
- [`after/screenshots/contacts-transition-contact-sheet.png`](after/screenshots/contacts-transition-contact-sheet.png): sampled default transition frames
- [`after/videos/first-lazy-dark.mp4`](after/videos/first-lazy-dark.mp4): non-white appearance, 3.67 seconds at 75 fps
- [`after/screenshots/dark-transition-contact-sheet.png`](after/screenshots/dark-transition-contact-sheet.png): sampled dark transition frames
- [`after/logs/app.log`](after/logs/app.log): application log for both fixed runs
- [`after/logs/xcodebuild-ios27.log`](after/logs/xcodebuild-ios27.log): successful iOS 27 simulator build

For each fixed run, accessibility state was explicitly queried after the interaction: the first Contacts row was `M, Marissa Castillo, 7766398169`, and the dark screen exposed `Lazy screen with dark content`. The same first-load Contacts path was also exercised on iOS 26.5; [`after/ios26/contacts-loaded.png`](after/ios26/contacts-loaded.png) records the resulting state.
