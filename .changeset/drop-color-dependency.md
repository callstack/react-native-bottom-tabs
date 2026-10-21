---
'@bottom-tabs/react-navigation': patch
---

Drop the `color` dependency in favour of React Native's `processColor`. `color` is ESM-only, so consumers had to extend `transformIgnorePatterns` before Jest would run at all
