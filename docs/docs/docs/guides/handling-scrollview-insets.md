# Handling Scroll View Insets

If you expirence issues with ScrollView content being below the tab bar, add `contentInsetAdjustmentBehavior="automatic"` to the ScrollView component.

```tsx
<ScrollView contentInsetAdjustmentBehavior="automatic">
  {/* content */}
</ScrollView>
```

## Keyboard-avoiding fixed content on iOS 26+

The iPhone Liquid Glass tab bar floats over full-bleed scene content. A
bottom-aligned control inside `KeyboardAvoidingView` therefore needs to reserve
the tab bar height while the keyboard is closed. Keep the full-screen background
on an outer view and apply the offset only to the keyboard-avoiding content. The
following pattern is for a visible native bottom bar without a bottom accessory
or `minimizeBehavior`:

```tsx
import { useBottomTabBarHeight } from 'react-native-bottom-tabs';
import { KeyboardAvoidingView, Platform, View } from 'react-native';

function Screen() {
  const tabBarHeight = useBottomTabBarHeight();
  const hasLiquidGlassBottomTabBar =
    Platform.OS === 'ios' &&
    !Platform.isPad &&
    !Platform.isTV &&
    parseFloat(String(Platform.Version)) >= 26;

  return (
    <View style={{ flex: 1, backgroundColor: 'white' }}>
      <KeyboardAvoidingView
        behavior="padding"
        style={{
          flex: 1,
          marginBottom: hasLiquidGlassBottomTabBar ? tabBarHeight : 0,
        }}
      >
        {/* Bottom-aligned content */}
      </KeyboardAvoidingView>
    </View>
  );
}
```

Do not apply this offset to the entire tab scene: scenes intentionally extend
behind translucent tab bars, and globally shortening them would also double
offsets already based on `useBottomTabBarHeight`. Custom, hidden, minimized,
sidebar, and accessory layouts should use spacing derived from their own visible
bottom element instead of this fixed-content pattern.
