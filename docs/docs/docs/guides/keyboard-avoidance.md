# Keyboard Avoidance

On iPhone, tab screens extend behind the tab bar. If you place an input at the bottom of a `KeyboardAvoidingView`, the tab bar covers it while the keyboard is closed.

To fix this, add the tab bar height as a bottom margin on the `KeyboardAvoidingView`:

```tsx
import { useBottomTabBarHeight } from 'react-native-bottom-tabs';
import { KeyboardAvoidingView, Platform, View } from 'react-native';

function Screen() {
  const tabBarHeight = useBottomTabBarHeight();
  const hasBottomTabBar =
    Platform.OS === 'ios' && !Platform.isPad && !Platform.isTV;

  return (
    <View style={{ flex: 1, backgroundColor: 'white' }}>
      <KeyboardAvoidingView
        behavior="padding"
        style={{
          flex: 1,
          marginBottom: hasBottomTabBar ? tabBarHeight : 0,
        }}
      >
        {/* content */}
      </KeyboardAvoidingView>
    </View>
  );
}
```

Keep the background color on the outer `View`, so it still fills the area behind the tab bar.
