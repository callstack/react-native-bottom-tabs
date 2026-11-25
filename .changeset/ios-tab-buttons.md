---
'react-native-bottom-tabs': patch
---

Fix 3 iOS bugs with tab bar buttons. On iOS 26 and newer a tab's `testID` was missing from its button, and a long press on a tab sent no `onTabLongPress` event. In a right-to-left layout a long press reported the wrong tab.
