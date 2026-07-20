---
"react-native-bottom-tabs": patch
---

Fix Android tab screens staying clipped at a transient startup height for the whole session. The onNativeLayout change-guard compared the outer view's size while reporting the inner layoutHolder's size, so a height caught mid-layout during startup was never re-reported. The guard is now keyed on layoutHolder itself, so a later correct layout re-reports and the view self-heals.
