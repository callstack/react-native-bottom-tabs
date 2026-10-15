import type {
  TabRouter,
  unstable_createStandardRouterNavigator,
} from 'expo-router';

import NativeBottomTabsContent from '../NativeBottomTabsContent';

jest.mock('react-native-bottom-tabs', () => ({
  __esModule: true,
  default: () => null,
}));

// Type-only stand-ins: Expo Router is only installed for its types, so
// nothing here may run.
declare const createStandardRouterNavigator: typeof unstable_createStandardRouterNavigator;
declare const tabRouter: typeof TabRouter;

const createTabs = () =>
  createStandardRouterNavigator(NativeBottomTabsContent, tabRouter);

declare const Tabs: ReturnType<typeof createTabs>;

it('infers the navigator props and screen options through Expo Router', () => {
  const acceptsNavigatorProps = () => (
    <Tabs
      tabBarActiveTintColor="#ff0000"
      tabBarInactiveTintColor="#808080"
      tabBar={({ state }) => state.routes.map((it) => it.name).join()}
      labeled
      sidebarAdaptable
      hapticFeedbackEnabled
    />
  );

  const acceptsScreenOptions = () => (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: 'Home', tabBarBadge: '3' }} />
    </Tabs>
  );

  const rejectsAWrongNavigatorProp = () => (
    // @ts-expect-error - labeled is a boolean
    <Tabs labeled="yes" />
  );

  const rejectsAnUnknownScreenOption = () => (
    <Tabs>
      {/* @ts-expect-error - not a screen option this navigator accepts */}
      <Tabs.Screen name="index" options={{ notARealOption: true }} />
    </Tabs>
  );

  expect([
    createTabs,
    acceptsNavigatorProps,
    acceptsScreenOptions,
    rejectsAWrongNavigatorProp,
    rejectsAnUnknownScreenOption,
  ]).toHaveLength(5);
});
