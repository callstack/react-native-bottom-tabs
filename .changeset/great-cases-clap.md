---
'react-native-bottom-tabs': patch
---

Fix custom tab bar height measurement for absolutely positioned tab bars. `useBottomTabBarHeight` now reports the correct height when `renderCustomTabBar` returns an absolutely positioned element, by measuring it with `onLayout` instead of measuring the wrapper `View`.
