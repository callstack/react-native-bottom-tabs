import {
  nativeBottomTabsNavigator,
  type NativeBottomTabNavigationOptions,
  type NativeBottomTabsEventMap,
  type NativeBottomTabsNavigatorProps,
} from '@bottom-tabs/navigation';
import {
  createStandardNavigationFactories,
  NavigationContainer,
  TabRouter,
  useTheme,
  type ParamListBase,
  type StandardNavigationTypeBagBase,
  type TabActionHelpers,
  type TabNavigationState,
  type TabRouterOptions,
} from '@react-navigation/native';
import { render } from '@testing-library/react-native';
import type * as React from 'react';
import { Text } from 'react-native';

let tabViewProps: Record<string, any>;

jest.mock('react-native-bottom-tabs', () => ({
  __esModule: true,
  default: (props: Record<string, any>) => {
    tabViewProps = props;
    return null;
  },
}));

interface NativeBottomTabsTypeBag extends StandardNavigationTypeBagBase {
  State: TabNavigationState<ParamListBase>;
  ScreenOptions: NativeBottomTabNavigationOptions;
  EventMap: NativeBottomTabsEventMap;
  RouterOptions: TabRouterOptions;
  ActionHelpers: TabActionHelpers<ParamListBase>;
  Navigator: React.ComponentType<NativeBottomTabsNavigatorProps>;
}

const { createNavigator } = createStandardNavigationFactories<
  NativeBottomTabsTypeBag,
  NativeBottomTabsNavigatorProps
>(nativeBottomTabsNavigator, TabRouter);

const Tab = createNavigator();

const { createNavigator: createThemedNavigator } =
  createStandardNavigationFactories<
    NativeBottomTabsTypeBag,
    NativeBottomTabsNavigatorProps
  >(nativeBottomTabsNavigator, TabRouter, () => {
    const { colors } = useTheme();

    return { defaultTintColors: { active: colors.primary } };
  });

const ThemedTab = createThemedNavigator();

const screens = (Navigator: typeof Tab) => (
  <Navigator.Navigator tabBarActiveTintColor="#ff0000">
    <Navigator.Screen name="Home" options={{ title: 'Home', tabBarBadge: '3' }}>
      {() => <Text>Home screen</Text>}
    </Navigator.Screen>
  </Navigator.Navigator>
);

beforeEach(() => {
  tabViewProps = {};
});

it('drives the native view through the shared navigator', async () => {
  await render(<NavigationContainer>{screens(Tab)}</NavigationContainer>);

  expect(
    tabViewProps.navigationState.routes.map((it: { name: string }) => it.name)
  ).toEqual(['Home']);
  expect(tabViewProps.tabBarActiveTintColor).toBe('#ff0000');
  expect(
    tabViewProps.getLabelText({ route: tabViewProps.navigationState.routes[0] })
  ).toBe('Home');
});

it('takes tint fallbacks from a mapper', async () => {
  await render(
    <NavigationContainer>
      <ThemedTab.Navigator>
        <ThemedTab.Screen name="Home">
          {() => <Text>Home screen</Text>}
        </ThemedTab.Screen>
      </ThemedTab.Navigator>
    </NavigationContainer>
  );

  expect(tabViewProps.tabBarActiveTintColor).toBe('rgb(0, 122, 255)');
});

it('types the navigator props and screen options', () => {
  const rejectsAWrongNavigatorProp = () => (
    // @ts-expect-error - a number is not a valid tint color
    <Tab.Navigator tabBarActiveTintColor={42} />
  );

  const rejectsAnUnknownScreenOption = () => (
    <Tab.Navigator>
      {/* @ts-expect-error - not a screen option this navigator accepts */}
      <Tab.Screen name="Home" options={{ notARealOption: true }}>
        {() => <Text>Home screen</Text>}
      </Tab.Screen>
    </Tab.Navigator>
  );

  expect([
    rejectsAWrongNavigatorProp,
    rejectsAnUnknownScreenOption,
  ]).toHaveLength(2);
});
