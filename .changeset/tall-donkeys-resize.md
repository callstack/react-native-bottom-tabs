---
'react-native-bottom-tabs': patch
---

Fix Android content not resizing when the tab bar visibility changes (`tabBarHidden`). The layout listener compared the container bounds, which stay the same when only the tab bar is hidden or shown, so the new `layoutHolder` size was never reported to JS and the content kept its stale height.
