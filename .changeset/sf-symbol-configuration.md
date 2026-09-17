---
"react-native-bottom-tabs": minor
"@bottom-tabs/react-navigation": minor
---

Support the full set of SF Symbol configuration options on tab icons.

`AppleIcon` now accepts `size`, `color`, `weight`, `scale`, `variableValue`, `variableValueMode`, `renderingMode`, `colors` and `colorRenderingMode` alongside `sfSymbol`, matching the options React Navigation exposes for SF Symbols. Symbol effects and content transitions are not included, because a tab bar item renders a still image and never runs symbol animations.

Existing icons are unaffected: with no options set, symbols render exactly as before.
