# SwiftPM example

Example app to demonstrate the SwiftPM integration for React Native Bottom Tabs.

The source code lives in [`packages/example-shared`](../../packages/example-shared), and is shared by all example apps.

## Run on iOS

From the repository root:

```sh
yarn install
yarn workspace example-swiftpm spm # generates SwiftPM dependencies
yarn workspace example-swiftpm start
```

In another terminal:

```sh
yarn workspace example-swiftpm ios
```

Running `pod install` is not needed since this app does not use CocoaPods.

## Tests

```sh
yarn workspace @bottom-tabs/example-shared typecheck
yarn workspace example-swiftpm e2e:ios
```

The shared Maestro flows use the shell's bundle ID through `APP_ID`.
