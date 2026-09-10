---
'@bottom-tabs/navigation': minor
'@bottom-tabs/react-navigation': minor
---

Move the native tabs implementation into a new framework-agnostic `@bottom-tabs/navigation` package built on the `standard-navigation` contract, and delegate the React Navigation entry point to it. This lets Expo Router SDK 56+ apps drive the same navigator through `unstable_integrateWithRouter` without loading a second copy of React Navigation
