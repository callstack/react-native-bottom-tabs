---
"react-native-bottom-tabs": major
---

Disable Apple-platform SVG tab icon support by default and add the `$RNBottomTabsEnableSVG` Podfile opt-in. The optional CoreSVG decoder is now scoped to bottom-tab icons instead of being registered app-wide with React Native's image loader.
