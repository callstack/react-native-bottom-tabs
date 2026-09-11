import {
  type Theme,
  DefaultTheme,
  NavigationContainer,
} from '@react-navigation/native';
import { act, render } from '@testing-library/react-native';
import * as React from 'react';
import { Text } from 'react-native';

import createNativeBottomTabNavigator from '../navigators/createNativeBottomTabNavigator';
import type {
  BottomTabBarProps,
  NativeBottomTabNavigationOptions,
} from '../types';

/**
 * These tests assert on the props the navigator hands to the native `TabView`,
 * which is the contract every consumer ultimately depends on.
 */
let tabViewProps: Record<string, any>;

jest.mock('react-native-bottom-tabs', () => ({
  __esModule: true,
  default: (props: Record<string, any>) => {
    tabViewProps = props;
    return null;
  },
}));

const Tab = createNativeBottomTabNavigator();

const ROUTES = ['Home', 'Explore'] as const;

type NavigatorProps = Partial<React.ComponentProps<typeof Tab.Navigator>> & {
  theme?: Theme;
};

const renderNavigator = async ({
  screenOptions,
  options = {},
  theme,
  ...navigatorProps
}: NavigatorProps & {
  options?: Partial<
    Record<(typeof ROUTES)[number], NativeBottomTabNavigationOptions>
  >;
} = {}) => {
  await render(
    <NavigationContainer theme={theme}>
      <Tab.Navigator screenOptions={screenOptions} {...navigatorProps}>
        {ROUTES.map((name) => (
          <Tab.Screen key={name} name={name} options={options[name]}>
            {() => <Text>{name} screen</Text>}
          </Tab.Screen>
        ))}
      </Tab.Navigator>
    </NavigationContainer>
  );
};

/** Every `getX` prop is called by `TabView` with the route it is rendering. */
const forRoute = (name: (typeof ROUTES)[number]) => {
  const route = tabViewProps.navigationState.routes.find(
    (it: { name: string }) => it.name === name
  );

  if (!route) {
    throw new Error(`No route named '${name}' in the navigation state.`);
  }

  return route;
};

beforeEach(() => {
  tabViewProps = {};
});

describe('navigator props', () => {
  it('rejects a prop of the wrong type', () => {
    type TintColor = React.ComponentProps<
      typeof Tab.Navigator
    >['tabBarActiveTintColor'];

    // @ts-expect-error - a number is not a valid tint color
    const invalidTintColor: TintColor = 42;

    expect(invalidTintColor).toBe(42);
  });
});

describe('navigation state', () => {
  it('passes the router state straight through to the tab view', async () => {
    await renderNavigator();

    expect(tabViewProps.navigationState.index).toBe(0);
    expect(
      tabViewProps.navigationState.routes.map((it: { name: string }) => it.name)
    ).toEqual(['Home', 'Explore']);
  });

  it('renders a scene through the descriptor', async () => {
    await renderNavigator();

    expect(tabViewProps.renderScene({ route: forRoute('Home') })).toBeTruthy();
  });
});

describe('screen options', () => {
  it.each([
    ['getBadge', 'tabBarBadge', '3'],
    ['getBadgeBackgroundColor', 'tabBarBadgeBackgroundColor', '#ff0000'],
    ['getBadgeTextColor', 'tabBarBadgeTextColor', '#00ff00'],
    ['getTestID', 'tabBarButtonTestID', 'home-tab'],
    ['getRole', 'role', 'search'],
    ['getIconRenderingMode', 'tabBarIconRenderingMode', 'original'],
    ['getActiveTintColor', 'tabBarActiveTintColor', '#123456'],
    ['getFreezeOnBlur', 'freezeOnBlur', true],
    ['getSceneStyle', 'sceneStyle', { backgroundColor: 'red' }],
    ['getPreventsDefault', 'preventsDefault', true],
  ] as const)('maps %s from the %s option', async (getter, option, value) => {
    await renderNavigator({ options: { Home: { [option]: value } } });

    expect(tabViewProps[getter]({ route: forRoute('Home') })).toEqual(value);
    expect(
      tabViewProps[getter]({ route: forRoute('Explore') })
    ).toBeUndefined();
  });

  it('reports a tab as hidden only when tabBarItemHidden is true', async () => {
    await renderNavigator({ options: { Home: { tabBarItemHidden: true } } });

    expect(tabViewProps.getHidden({ route: forRoute('Home') })).toBe(true);
    expect(tabViewProps.getHidden({ route: forRoute('Explore') })).toBe(false);
  });

  it('defaults lazy to true', async () => {
    await renderNavigator({ options: { Home: { lazy: false } } });

    expect(tabViewProps.getLazy({ route: forRoute('Home') })).toBe(false);
    expect(tabViewProps.getLazy({ route: forRoute('Explore') })).toBe(true);
  });

  it('calls tabBarIcon with the focused state', async () => {
    const tabBarIcon = jest.fn(() => ({ sfSymbol: 'house' }) as const);

    await renderNavigator({ options: { Home: { tabBarIcon } } });

    expect(
      tabViewProps.getIcon({ route: forRoute('Home'), focused: true })
    ).toEqual({ sfSymbol: 'house' });
    expect(tabBarIcon).toHaveBeenCalledWith({ focused: true });
  });

  it('returns no icon when the option is unset', async () => {
    await renderNavigator();

    expect(
      tabViewProps.getIcon({ route: forRoute('Home'), focused: false })
    ).toBeNull();
  });
});

describe('label', () => {
  it('prefers tabBarLabel over title', async () => {
    await renderNavigator({
      options: { Home: { tabBarLabel: 'Label', title: 'Title' } },
    });

    expect(tabViewProps.getLabelText({ route: forRoute('Home') })).toBe(
      'Label'
    );
  });

  it('falls back to title when tabBarLabel is unset', async () => {
    await renderNavigator({ options: { Home: { title: 'Title' } } });

    expect(tabViewProps.getLabelText({ route: forRoute('Home') })).toBe(
      'Title'
    );
  });

  it('falls back to the route name when neither is set', async () => {
    await renderNavigator();

    expect(tabViewProps.getLabelText({ route: forRoute('Home') })).toBe('Home');
  });
});

describe('tint colors', () => {
  const theme: Theme = {
    ...DefaultTheme,
    colors: {
      ...DefaultTheme.colors,
      primary: '#ff0000',
      text: '#000000',
      card: '#ffffff',
    },
  };

  it('derives defaults from the navigation theme', async () => {
    await renderNavigator({ theme });

    expect(tabViewProps.tabBarActiveTintColor).toBe('#ff0000');
    // A 50% mix of the theme's text and card colors.
    expect(tabViewProps.tabBarInactiveTintColor).toBe('#808080');
  });

  it('lets the navigator props win over the theme', async () => {
    await renderNavigator({
      theme,
      tabBarActiveTintColor: '#00ff00',
      tabBarInactiveTintColor: '#0000ff',
    });

    expect(tabViewProps.tabBarActiveTintColor).toBe('#00ff00');
    expect(tabViewProps.tabBarInactiveTintColor).toBe('#0000ff');
  });
});

describe('tab press', () => {
  const pressTab = async (index: number) => {
    await act(async () => {
      tabViewProps.onIndexChange(index);
    });
  };

  it('navigates to the pressed tab', async () => {
    await renderNavigator();

    await pressTab(1);

    expect(tabViewProps.navigationState.index).toBe(1);
  });

  it('emits tabPress before navigating', async () => {
    const tabPress = jest.fn();

    await renderNavigator({ screenListeners: { tabPress } });
    await pressTab(1);

    expect(tabPress).toHaveBeenCalledTimes(1);
    expect(tabViewProps.navigationState.index).toBe(1);
  });

  it('does not navigate when a listener prevents the default', async () => {
    await renderNavigator({
      screenListeners: {
        tabPress: (event: { preventDefault: () => void }) =>
          event.preventDefault(),
      },
    });

    await pressTab(1);

    expect(tabViewProps.navigationState.index).toBe(0);
  });

  it('does not navigate when the screen sets preventsDefault', async () => {
    await renderNavigator({ options: { Explore: { preventsDefault: true } } });

    await pressTab(1);

    expect(tabViewProps.navigationState.index).toBe(0);
  });

  it('emits tabPress on the focused tab but does not re-navigate', async () => {
    const tabPress = jest.fn();

    await renderNavigator({ screenListeners: { tabPress } });
    await pressTab(0);

    expect(tabPress).toHaveBeenCalledTimes(1);
    expect(tabViewProps.navigationState.index).toBe(0);
  });

  it('ignores an out-of-range index', async () => {
    await renderNavigator();

    await pressTab(99);

    expect(tabViewProps.navigationState.index).toBe(0);
  });
});

describe('tab long press', () => {
  it('emits tabLongPress for the pressed tab', async () => {
    const tabLongPress = jest.fn();

    await renderNavigator({ screenListeners: { tabLongPress } });

    await act(async () => {
      tabViewProps.onTabLongPress(1);
    });

    expect(tabLongPress).toHaveBeenCalledTimes(1);
  });

  it('ignores an out-of-range index', async () => {
    const tabLongPress = jest.fn();

    await renderNavigator({ screenListeners: { tabLongPress } });

    await act(async () => {
      tabViewProps.onTabLongPress(99);
    });

    expect(tabLongPress).not.toHaveBeenCalled();
  });
});

describe('custom tab bar', () => {
  it('is called with the navigation state, descriptors and navigation', async () => {
    const tabBar = jest.fn((_: BottomTabBarProps) => null);

    await renderNavigator({ tabBar });

    tabViewProps.tabBar();

    const props = tabBar.mock.calls[0]![0];

    expect(props.state.routes.map((it) => it.name)).toEqual([
      'Home',
      'Explore',
    ]);
    expect(Object.keys(props.descriptors)).toHaveLength(2);
    expect(typeof props.navigation.emit).toBe('function');
  });

  /**
   * `BottomTabBar` from `@react-navigation/bottom-tabs` reads `state.key` and
   * the per-route `navigation` and `route` off the descriptors. The standard
   * navigation contract projects those away, so the navigator has to keep
   * building the React Navigation state itself.
   */
  it('is called with descriptors carrying the full React Navigation shape', async () => {
    const tabBar = jest.fn((_: BottomTabBarProps) => null);

    await renderNavigator({ tabBar });

    tabViewProps.tabBar();

    const props = tabBar.mock.calls[0]![0];
    const descriptor = props.descriptors[props.state.routes[0]!.key]!;

    expect(typeof props.state.key).toBe('string');
    expect(typeof descriptor.navigation.dispatch).toBe('function');
    expect(typeof descriptor.navigation.navigate).toBe('function');
    expect(descriptor.route.name).toBe('Home');
    expect(typeof descriptor.render).toBe('function');
  });

  it('is left undefined when no custom tab bar is given', async () => {
    await renderNavigator();

    expect(tabViewProps.tabBar).toBeUndefined();
  });
});
