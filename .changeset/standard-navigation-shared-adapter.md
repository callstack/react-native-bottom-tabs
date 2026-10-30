---
'@bottom-tabs/standard-navigation': minor
'@bottom-tabs/react-navigation': minor
---

Move the native tabs implementation into a new framework-agnostic `@bottom-tabs/standard-navigation` package built on the `standard-navigation` contract, so Expo Router SDK 56+ apps can drive the same navigator through `unstable_createStandardRouterNavigator` without loading a second copy of React Navigation.
