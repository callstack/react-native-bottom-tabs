---
'react-native-bottom-tabs': patch
---

Fix Android build with AGP 9 built-in Kotlin: remove the unused `kotlin-kapt` plugin, which is incompatible with built-in Kotlin
