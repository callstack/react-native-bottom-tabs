---
'react-native-bottom-tabs': patch
---

Respect user-supplied `tabBarHidden` on `TabView`. The prop was wired natively but the JS wrapper hardcoded `tabBarHidden={!!renderCustomTabBar}` after the `{...props}` spread, so any user value was silently overwritten. The prop is now declared on the public `TabView` API and only falls back to the custom-tab-bar default when the caller omits it, which lets iOS 26+ users hide the SwiftUI-backed tab bar from JS again.
