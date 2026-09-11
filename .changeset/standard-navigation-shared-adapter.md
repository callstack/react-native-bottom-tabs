---
'@bottom-tabs/navigation': minor
'@bottom-tabs/react-navigation': minor
---

Move the native tabs implementation into a new framework-agnostic `@bottom-tabs/navigation` package built on the `standard-navigation` contract. This lets Expo Router SDK 56+ apps drive the same navigator through `unstable_integrateWithRouter` without loading a second copy of React Navigation.

`createNativeBottomTabNavigator` renders through the shared navigator, and keeps building its own state with `useNavigationBuilder`, so `state.key` and the per-route `navigation` and `route` objects a custom `tabBar` reads stay intact.

`@bottom-tabs/react-navigation` now requires `@react-navigation/native` 7.3.0 or newer, which is the version that introduced `createStandardNavigationFactories` used by the documented shared-navigator recipe
