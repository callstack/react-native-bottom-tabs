# Shared example app

This private workspace contains the example UI, assets, and Maestro flows. Both
`apps/example` (CocoaPods / React Native Test App) and `apps/example-swiftpm`
(Community CLI / SwiftPM) register its default `App` export.

Add or edit screens in `src/` and assets in `assets/`; every example shell sees
those changes through Metro without copying files or publishing this package.
`babel.config.js` resolves workspace libraries to source. Each shell owns its
Metro configuration: the existing example uses rnx-kit, and the SwiftPM example
extends the Community CLI defaults for workspace dependency resolution and
shared asset URLs.

## Adding another shell

1. Scaffold the native app under `apps/`.
2. Add `@bottom-tabs/example-shared: workspace:*` and the shared app's runtime
   dependencies to the shell's `package.json`. Native dependencies must be direct
   shell dependencies so React Native autolinking discovers them.
3. Register the default export from `@bottom-tabs/example-shared` in the shell's
   `index.js`, using its own `app.json` registration name.
4. Reuse `@bottom-tabs/example-shared/babel` and keep the shell's own Metro
   configuration.
5. Configure native resources and integration for that shell. The examples use
   React Native Paper's MaterialCommunityIcons font; include it in the native app.
6. Run the flows in `e2e/` with `APP_ID` set to the shell's bundle/application ID.

Keep native app delegates, project files, dependency-manager setup, permissions,
and registration names in the shells. Feature code belongs here.

From the repository root:

```sh
yarn workspace @bottom-tabs/example-shared typecheck
yarn workspace react-native-bottom-tabs-example e2e:ios
yarn workspace example-swiftpm e2e:ios
```

## Updating dependencies

Shared runtime dependency versions are maintained in the root `yarn.config.cjs`.
All three example workspaces keep explicit dependency declarations; Yarn
constraints synchronize them. The SwiftPM shell has explicit overrides for its
patched native dependencies. Tooling dependencies remain workspace-specific.

After editing the central versions (and checking any affected SwiftPM patches):

```sh
yarn constraints --fix
yarn install
```

CI runs `yarn constraints` to reject missing or mismatched declarations. When
adding another example shell, add its workspace path to the `examples` set in
`yarn.config.cjs` and run the same commands.
