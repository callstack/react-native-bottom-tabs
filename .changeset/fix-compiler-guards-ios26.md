---
"react-native-bottom-tabs": patch
---

Add `#if compiler(>=6.2)` guards to iOS-26 SwiftUI symbols in BottomAccessoryProvider.swift and NewTabView.swift to fix compilation on Xcode < 26
