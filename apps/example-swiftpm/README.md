# SwiftPM example

An iOS-only React Native 0.87.1 Community CLI shell using SwiftPM for the shared
bottom-tabs example app.
All screens, components, assets, and test flows live in
[`packages/example-shared`](../../packages/example-shared). The CocoaPods shell
remains in `apps/example`.

## Run on iOS

From the repository root:

```sh
yarn install --immutable
yarn workspace example-swiftpm spm
yarn workspace example-swiftpm start
```

In another terminal:

```sh
yarn workspace example-swiftpm ios
```

Use a separate Metro port when running both shells at once, for example
`start --port 8083` and `ios --port 8083`.

The app's Metro configuration includes the workspace root and resolves shared
code against this shell's dependencies. It also maps shared asset URLs back to
Metro's asset handler. These settings are needed because the CLI template assumes
an app whose source and dependencies are contained within its own directory.
Restart Metro after changing this configuration.

SwiftPM setup is required on fresh checkouts and CI: generated Codegen packages
and React Native XCFrameworks are not committed. Open
`ios/ExampleSwiftPM.xcodeproj` when building through Xcode. Do not run `pod install`
for this shell.

## How this shell was created

```sh
npx @react-native-community/cli@20.2.0 init ExampleSwiftPM \
  --directory apps/example-swiftpm --title example-swiftpm \
  --package-name bottomtabs.exampleswiftpm --version 0.87.1 \
  --skip-install --skip-git-init --install-pods false
```

The generated Android project and Android-specific scripts and CLI dependency
were removed; this shell targets iOS only.

After installing dependencies, the native project was migrated with
`react-native spm add --deintegrate`. Dependencies without manifests were prepared
with `react-native spm scaffold`. Their manifests and required compatibility fixes
are preserved using Yarn patches in the repository's `.yarn/patches` directory.

The template's Podfile is retained only as a note: the app has no CocoaPods
integration. Its bundle ID is `bottomtabs.exampleswiftpm`.

## Tests

```sh
yarn workspace @bottom-tabs/example-shared typecheck
yarn workspace example-swiftpm e2e:ios
```

The shared Maestro flows use the shell's bundle ID through `APP_ID`.

`yarn workspace example-swiftpm spm` invokes React Native's standard SwiftPM CLI
directly. Run it after checkout to prepare the generated dependencies for your
machine. The five dependency patches are scoped to this shell;
the CocoaPods shell keeps its ordinary npm dependencies.

## Validation

Validated on September 8, 2026 with Xcode 26.5:

- Debug and Release simulator builds succeeded (arm64).
- In Debug and Release, using agent-device, opened the shared examples list,
  selected **Three Tabs**,
  and switched Albums → Article → Contacts on iOS **18.6** (iPhone 16 Pro) and
  **26.0** (iPhone 17 Pro). The article and contact content, tab icons, and album
  artwork rendered correctly.
- Yarn patches survived installation, and subsequent SwiftPM setup succeeded.
- The remaining example screens were not exercised in this pass.

The repository's existing Jest test is only a TODO; its current Babel/Flow setup
fails before that placeholder can run. This is separate from the device and asset
checks above.
