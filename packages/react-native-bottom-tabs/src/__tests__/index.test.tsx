import React from 'react';
import TestRenderer, { act } from 'react-test-renderer';
import TabView from '../TabView';

jest.mock('../TabViewNativeComponent', () => {
  const ReactModule = require('react');
  return ReactModule.forwardRef((props: object, ref: React.Ref<unknown>) =>
    ReactModule.createElement('NativeTabView', { ...props, ref })
  );
});

const renderTabView = (
  routes: Array<{ key: string; title: string; iconSize?: number }>,
  getIconSize?: (props: {
    route: (typeof routes)[number];
  }) => number | undefined
) => {
  let renderer: TestRenderer.ReactTestRenderer;

  act(() => {
    renderer = TestRenderer.create(
      <TabView
        navigationState={{ index: 0, routes }}
        renderScene={() => null}
        onIndexChange={jest.fn()}
        getIconSize={getIconSize}
      />
    );
  });

  return renderer!.root.find(
    (node) => (node.type as unknown) === 'NativeTabView'
  ).props;
};

describe('icon size', () => {
  it('leaves the size unset to preserve native defaults', () => {
    const { iconSizes } = renderTabView([{ key: 'home', title: 'Home' }]);

    expect(iconSizes).toEqual([0]);
  });

  it('passes a per-route override to native', () => {
    const { iconSizes } = renderTabView([
      { key: 'profile', title: 'Profile', iconSize: 34 },
    ]);

    expect(iconSizes).toEqual([34]);
  });

  it('supports custom route types through getIconSize', () => {
    const routes = [{ key: 'profile', title: 'Profile' }];
    const { iconSizes } = renderTabView(routes, () => 36);

    expect(iconSizes).toEqual([36]);
  });
});
