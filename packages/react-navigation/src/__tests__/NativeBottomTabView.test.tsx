import TestRenderer, { act } from 'react-test-renderer';
import NativeBottomTabView from '../views/NativeBottomTabView';

jest.mock('@react-navigation/native', () => ({
  CommonActions: { navigate: jest.fn() },
}));

jest.mock('react-native-bottom-tabs', () => {
  const React = require('react');
  return (props: object) => React.createElement('TabView', props);
});

describe('tabBarIconSize', () => {
  it('maps per-screen overrides and preserves an unset default', () => {
    const state = {
      index: 0,
      key: 'tabs',
      routeNames: ['Home', 'Profile'],
      history: [],
      preloadedRouteKeys: [],
      stale: false as const,
      type: 'tab' as const,
      routes: [
        { key: 'home', name: 'Home' },
        { key: 'profile', name: 'Profile' },
      ],
    };
    const descriptors = {
      home: {
        options: {},
        render: jest.fn(() => null),
      },
      profile: {
        options: { tabBarIconSize: 34 },
        render: jest.fn(() => null),
      },
    };
    let renderer: TestRenderer.ReactTestRenderer;

    act(() => {
      renderer = TestRenderer.create(
        <NativeBottomTabView
          state={state}
          descriptors={descriptors as never}
          navigation={{ emit: jest.fn(), dispatch: jest.fn() } as never}
        />
      );
    });

    const { navigationState } = renderer!.root.find(
      (node) => (node.type as unknown) === 'TabView'
    ).props;
    expect(navigationState.routes[0].iconSize).toBeUndefined();
    expect(navigationState.routes[1].iconSize).toBe(34);
  });
});
