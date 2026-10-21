import { render } from '@testing-library/react-native';

import NativeBottomTabsContent from '../NativeBottomTabsContent';
import type {
  NativeBottomTabNavigationOptions,
  NativeBottomTabsNavigatorProps,
  NavigatorRoute,
} from '../types';

let tabViewProps: Record<string, any>;

jest.mock('react-native-bottom-tabs', () => ({
  __esModule: true,
  default: (props: Record<string, any>) => {
    tabViewProps = props;
    return null;
  },
}));

const ROUTES = ['Home', 'Explore'] as const;

type RouteName = (typeof ROUTES)[number];

const route = (name: RouteName): NavigatorRoute => ({
  key: `${name}-key`,
  name,
  params: undefined,
  href: undefined,
});

const renderContent = async ({
  index = 0,
  routes = ROUTES.map(route),
  options = {},
  defaultPrevented = false,
  ...props
}: NativeBottomTabsNavigatorProps & {
  index?: number;
  routes?: NavigatorRoute[];
  options?: Partial<Record<RouteName, NativeBottomTabNavigationOptions>>;
  defaultPrevented?: boolean;
  backBehavior?: unknown;
} = {}) => {
  const actions = { navigate: jest.fn(), back: jest.fn() };
  const emitter = {
    emit: jest.fn((event: { type: string; target?: string }) => ({
      ...event,
      defaultPrevented,
    })),
  };

  const descriptors = Object.fromEntries(
    routes.map((it) => [
      it.key,
      {
        options: options[it.name as RouteName] ?? {},
        render: () => `${it.name} scene`,
      },
    ])
  );

  await render(
    <NativeBottomTabsContent
      state={{ index, routes }}
      descriptors={descriptors}
      actions={actions}
      emitter={emitter}
      {...props}
    />
  );

  return { actions, emitter };
};

beforeEach(() => {
  tabViewProps = {};
});

describe('navigation state', () => {
  it('passes the contract state straight through to the tab view', async () => {
    await renderContent();

    expect(tabViewProps.navigationState.index).toBe(0);
    expect(
      tabViewProps.navigationState.routes.map((it: NavigatorRoute) => it.name)
    ).toEqual(['Home', 'Explore']);
  });

  it('renders a scene through the descriptor', async () => {
    await renderContent();

    expect(tabViewProps.renderScene({ route: route('Home') })).toBe(
      'Home scene'
    );
  });

  it('renders nothing when there are no routes', async () => {
    await renderContent({ routes: [] });

    expect(tabViewProps.navigationState).toBeUndefined();
  });
});

describe('tint colors', () => {
  it('falls back to the defaults supplied by the integrator', async () => {
    await renderContent({
      defaultTintColors: { active: '#ff0000', inactive: '#808080' },
    });

    expect(tabViewProps.tabBarActiveTintColor).toBe('#ff0000');
    expect(tabViewProps.tabBarInactiveTintColor).toBe('#808080');
  });

  it('lets explicit props win over the defaults', async () => {
    await renderContent({
      defaultTintColors: { active: '#ff0000', inactive: '#808080' },
      tabBarActiveTintColor: '#00ff00',
      tabBarInactiveTintColor: '#0000ff',
    });

    expect(tabViewProps.tabBarActiveTintColor).toBe('#00ff00');
    expect(tabViewProps.tabBarInactiveTintColor).toBe('#0000ff');
  });
});

describe('router options', () => {
  it('does not forward backBehavior to the native view', async () => {
    await renderContent({ backBehavior: 'history' });

    expect(tabViewProps).not.toHaveProperty('backBehavior');
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
    await renderContent({ options: { Home: { [option]: value } } });

    expect(tabViewProps[getter]({ route: route('Home') })).toEqual(value);
    expect(tabViewProps[getter]({ route: route('Explore') })).toBeUndefined();
  });

  it('reports a tab as hidden only when tabBarItemHidden is true', async () => {
    await renderContent({ options: { Home: { tabBarItemHidden: true } } });

    expect(tabViewProps.getHidden({ route: route('Home') })).toBe(true);
    expect(tabViewProps.getHidden({ route: route('Explore') })).toBe(false);
  });

  it('defaults lazy to true', async () => {
    await renderContent({ options: { Home: { lazy: false } } });

    expect(tabViewProps.getLazy({ route: route('Home') })).toBe(false);
    expect(tabViewProps.getLazy({ route: route('Explore') })).toBe(true);
  });

  it('calls tabBarIcon with the focused state', async () => {
    const tabBarIcon = jest.fn(() => ({ sfSymbol: 'house' }) as const);

    await renderContent({ options: { Home: { tabBarIcon } } });

    expect(
      tabViewProps.getIcon({ route: route('Home'), focused: true })
    ).toEqual({ sfSymbol: 'house' });
    expect(tabBarIcon).toHaveBeenCalledWith({ focused: true });
  });

  it('returns no icon when the option is unset', async () => {
    await renderContent();

    expect(
      tabViewProps.getIcon({ route: route('Home'), focused: false })
    ).toBeNull();
  });
});

describe('label', () => {
  it('prefers tabBarLabel over title', async () => {
    await renderContent({
      options: { Home: { tabBarLabel: 'Label', title: 'Title' } },
    });

    expect(tabViewProps.getLabelText({ route: route('Home') })).toBe('Label');
  });

  it('falls back to title when tabBarLabel is unset', async () => {
    await renderContent({ options: { Home: { title: 'Title' } } });

    expect(tabViewProps.getLabelText({ route: route('Home') })).toBe('Title');
  });

  it('falls back to the route name when neither is set', async () => {
    await renderContent();

    expect(tabViewProps.getLabelText({ route: route('Home') })).toBe('Home');
  });
});

describe('tab press', () => {
  it('emits tabPress and navigates to the pressed tab', async () => {
    const { actions, emitter } = await renderContent();

    tabViewProps.onIndexChange(1);

    expect(emitter.emit).toHaveBeenCalledWith({
      type: 'tabPress',
      target: 'Explore-key',
      canPreventDefault: true,
    });
    expect(actions.navigate).toHaveBeenCalledWith('Explore', undefined);
  });

  it('does not navigate when the event default was prevented', async () => {
    const { actions } = await renderContent({ defaultPrevented: true });

    tabViewProps.onIndexChange(1);

    expect(actions.navigate).not.toHaveBeenCalled();
  });

  it('does not navigate when the screen sets preventsDefault', async () => {
    const { actions } = await renderContent({
      options: { Explore: { preventsDefault: true } },
    });

    tabViewProps.onIndexChange(1);

    expect(actions.navigate).not.toHaveBeenCalled();
  });

  it('emits tabPress on the focused tab but does not re-navigate', async () => {
    const { actions, emitter } = await renderContent();

    tabViewProps.onIndexChange(0);

    expect(emitter.emit).toHaveBeenCalledTimes(1);
    expect(actions.navigate).not.toHaveBeenCalled();
  });

  it('ignores an out-of-range index', async () => {
    const { actions, emitter } = await renderContent();

    tabViewProps.onIndexChange(99);

    expect(emitter.emit).not.toHaveBeenCalled();
    expect(actions.navigate).not.toHaveBeenCalled();
  });
});

describe('tab long press', () => {
  it('emits tabLongPress for the pressed tab', async () => {
    const { emitter } = await renderContent();

    tabViewProps.onTabLongPress(1);

    expect(emitter.emit).toHaveBeenCalledWith({
      type: 'tabLongPress',
      target: 'Explore-key',
    });
  });

  it('ignores an out-of-range index', async () => {
    const { emitter } = await renderContent();

    tabViewProps.onTabLongPress(99);

    expect(emitter.emit).not.toHaveBeenCalled();
  });
});

describe('custom tab bar', () => {
  it('is called with the contract vocabulary', async () => {
    const tabBar = jest.fn(() => null);

    const { actions, emitter } = await renderContent({ tabBar });

    tabViewProps.tabBar();

    expect(tabBar).toHaveBeenCalledWith({
      state: { index: 0, routes: ROUTES.map(route) },
      descriptors: expect.any(Object),
      actions,
      emitter,
    });
  });

  it('is left undefined when no custom tab bar is given', async () => {
    await renderContent();

    expect(tabViewProps.tabBar).toBeUndefined();
  });
});
