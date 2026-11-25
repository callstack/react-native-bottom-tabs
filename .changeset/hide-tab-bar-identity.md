---
'react-native-bottom-tabs': patch
---

Fix toggling `tabBarHidden` on iOS rebuilding the tab content, which dismissed sheets presented from the tab and dropped text input focus
