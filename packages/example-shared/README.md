# Shared Source Code for the Example Apps

This private workspace contains the example UI, assets, and end-to-end tests.

Both `apps/example` (CocoaPods / React Native Test App) and `apps/example-swiftpm` (Community CLI / SwiftPM) register its default `App` export.

Add or edit screens in `src/` and assets in `assets/` and it will reflect in all example apps.

Example apps need special `metro.config.js` configuration to resolve assets from outside their own package. See `apps/example/metro.config.js` and `apps/example-swiftpm/metro.config.js`.

## End-to-end tests

The tests in `e2e/` run with [e2e](https://e2e.com) on iOS simulators and Android emulators. They need no model or API key. CI runs them on every pull request (`.github/workflows/e2e.yml`).

Build an example app, then run its tests from the repository root. Each run installs that build on the device first.

```sh
# apps/example on iOS, after `pod install --project-directory=ios` there
yarn workspace react-native-bottom-tabs-example e2e:build:ios
yarn workspace react-native-bottom-tabs-example e2e:ios

# apps/example on Android
yarn workspace react-native-bottom-tabs-example e2e:build:android
yarn workspace react-native-bottom-tabs-example e2e:android

# apps/example-swiftpm, after `yarn workspace example-swiftpm spm`
yarn workspace example-swiftpm e2e:build:ios
yarn workspace example-swiftpm e2e:ios
```

- The builds are Release builds with the JavaScript bundled, so Metro is not needed. Build again after a change to the library or to this workspace.
- The iOS tests expect iOS 26 or newer.
- The Android build is for an `arm64-v8a` emulator. Set `E2E_ANDROID_ABI=x86_64` for an x86_64 one.
- The tests use every booted simulator or emulator of the platform. Set `E2E_DEVICE` to the name or id of one device to use only that one.
- Arguments after the script name go to `e2e run`. `e2e:ios e2e/tab-view.e2e.ts` runs one file and `e2e:ios --grep "long press"` the tests with a matching title.
- `yarn workspace @bottom-tabs/example-shared e2e doctor` checks the devices and the builds.
- Results go to `.e2e/` in this workspace. A failed test prints the path of its trace page, which has the screen at the failure.

### Writing a test

Import `test` and `describe` from `e2e/support/test.ts`, which installs the build. `e2e/support/example.ts` has `openExample` to launch the app on an example screen, and `tab` and `button` to find a tab or a button by its title on both platforms. `yarn workspace @bottom-tabs/example-shared e2e guide writing-tests` prints the guide to the test API.

## Updating dependencies

Shared runtime dependency versions are maintained in the root `yarn.config.cjs`, so all example apps align on the same versions.

The SwiftPM shell has explicit overrides for its patched native dependencies (automatically generated).

After editing the central versions (and checking any affected SwiftPM patches):

```sh
yarn constraints --fix
yarn install
```

CI runs `yarn constraints` to reject missing or mismatched declarations. When
adding another example app, add its workspace path to the `examples` set in
`yarn.config.cjs` and run the same commands.
