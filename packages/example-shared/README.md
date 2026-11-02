# Shared Source Code for the Example Apps

This private workspace contains the example UI, assets, and Maestro flows.

Both `apps/example` (CocoaPods / React Native Test App) and `apps/example-swiftpm` (Community CLI / SwiftPM) register its default `App` export.

Add or edit screens in `src/` and assets in `assets/` and it will reflect in all example apps.

Example apps need special `metro.config.js` configuration to resolve assets from outside their own package. See `apps/example/metro.config.js` and `apps/example-swiftpm/metro.config.js`.

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
