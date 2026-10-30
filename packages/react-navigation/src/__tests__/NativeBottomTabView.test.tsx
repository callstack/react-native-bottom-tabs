import { render } from '@testing-library/react-native';

import NativeBottomTabView from '../views/NativeBottomTabView';

let tabViewProps: Record<string, any>;

jest.mock('react-native-bottom-tabs', () => ({
  __esModule: true,
  default: (props: Record<string, any>) => {
    tabViewProps = props;
    return null;
  },
}));

const state = {
  key: 'tab-state',
  index: 0,
  routeNames: ['Home', 'Explore'],
  routes: [
    { key: 'Home-key', name: 'Home' },
    { key: 'Explore-key', name: 'Explore' },
  ],
  type: 'tab' as const,
  stale: false as const,
  history: [],
  preloadedRouteKeys: [],
};

const renderView = async (props: Record<string, any> = {}) => {
  const navigation = {
    dispatch: jest.fn(),
    goBack: jest.fn(),
    emit: jest.fn(() => ({ defaultPrevented: false })),
  };

  const descriptors = Object.fromEntries(
    state.routes.map((route) => [
      route.key,
      { options: {}, render: () => `${route.name} scene` },
    ])
  );

  await render(
    <NativeBottomTabView
      {...(props as any)}
      state={state as any}
      navigation={navigation as any}
      descriptors={descriptors as any}
    />
  );

  return { navigation };
};

beforeEach(() => {
  tabViewProps = {};
});

it('renders the tab view from React Navigation props', async () => {
  await renderView();

  expect(tabViewProps.navigationState.index).toBe(0);
  expect(tabViewProps.getLabelText({ route: state.routes[0] })).toBe('Home');
});

it('dispatches a navigate action targeting the navigator state', async () => {
  const { navigation } = await renderView();

  tabViewProps.onIndexChange(1);

  expect(navigation.dispatch).toHaveBeenCalledWith(
    expect.objectContaining({ target: 'tab-state' })
  );
});

it('emits tab events through the navigation helpers', async () => {
  const { navigation } = await renderView();

  tabViewProps.onTabLongPress(1);

  expect(navigation.emit).toHaveBeenCalledWith({
    type: 'tabLongPress',
    target: 'Explore-key',
  });
});

it('passes navigation to a custom tab bar', async () => {
  const tabBar = jest.fn(() => null);

  const { navigation } = await renderView({ tabBar });

  tabViewProps.tabBar();

  expect(tabBar).toHaveBeenCalledWith(
    expect.objectContaining({ navigation, descriptors: expect.any(Object) })
  );
});
