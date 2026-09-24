import { ExpoRouterTabs } from '../tabs';

export const tintColors = () => (
  <ExpoRouterTabs
    tabBarActiveTintColor="#ff0000"
    tabBarInactiveTintColor="#808080"
  />
);

export const defaultTintColors = () => (
  <ExpoRouterTabs defaultTintColors={{ active: '#ff0000' }} />
);

export const customTabBar = () => (
  <ExpoRouterTabs
    tabBar={({ state }) => state.routes.map((it) => it.name).join()}
  />
);

export const nativeProps = () => (
  <ExpoRouterTabs labeled sidebarAdaptable hapticFeedbackEnabled />
);

export const screenOptions = () => (
  <ExpoRouterTabs>
    <ExpoRouterTabs.Screen
      name="index"
      options={{ title: 'Home', tabBarBadge: '3' }}
    />
  </ExpoRouterTabs>
);

export const rejectsAWrongNavigatorProp = () => (
  // @ts-expect-error - a number is not a valid tint color
  <ExpoRouterTabs tabBarActiveTintColor={42} />
);

export const rejectsAnUnknownScreenOption = () => (
  <ExpoRouterTabs>
    {/* @ts-expect-error - not a screen option this navigator accepts */}
    <ExpoRouterTabs.Screen name="index" options={{ notARealOption: true }} />
  </ExpoRouterTabs>
);

it('type checks the navigator surface', () => {
  expect(typeof ExpoRouterTabs).toBe('object');
});
