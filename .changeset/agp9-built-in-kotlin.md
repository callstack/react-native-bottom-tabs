---
'react-native-bottom-tabs': patch
---

Fix Android build with AGP 9 built-in Kotlin: skip applying the `kotlin-android` plugin when AGP has already registered the `kotlin` extension
