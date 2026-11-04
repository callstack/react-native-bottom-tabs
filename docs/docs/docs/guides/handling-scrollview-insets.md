# Handling Scroll View Insets

If you expirence issues with ScrollView content being below the tab bar, add `contentInsetAdjustmentBehavior="automatic"` to the ScrollView component.

```tsx
<ScrollView contentInsetAdjustmentBehavior="automatic">
  {/* content */}
</ScrollView>
```
