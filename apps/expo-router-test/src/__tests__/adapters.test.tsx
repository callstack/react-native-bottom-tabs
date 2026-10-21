import { NavigationContainer } from '@react-navigation/native';
import { act, render } from '@testing-library/react-native';
import { renderRouter } from 'expo-router/testing-library';
import { Text } from 'react-native';

import { ExpoRouterTabs, ReactNavigationTabs } from '../tabs';

let tabViewProps: Record<string, any>;

jest.mock('react-native-bottom-tabs', () => ({
  __esModule: true,
  default: (props: Record<string, any>) => {
    tabViewProps = props;
    return null;
  },
}));

const OPTIONS = {
  index: { title: 'Home', tabBarBadge: '3' },
  explore: { title: 'Explore' },
};

const adapters = [
  {
    name: 'expo-router',
    render: async () => {
      await renderRouter(
        {
          _layout: () => (
            <ExpoRouterTabs>
              <ExpoRouterTabs.Screen name="index" options={OPTIONS.index} />
              <ExpoRouterTabs.Screen name="explore" options={OPTIONS.explore} />
            </ExpoRouterTabs>
          ),
          index: () => <Text>index scene</Text>,
          explore: () => <Text>explore scene</Text>,
        },
        { initialUrl: '/' }
      );
    },
  },
  {
    name: 'react-navigation',
    render: async () => {
      await render(
        <NavigationContainer>
          <ReactNavigationTabs.Navigator>
            <ReactNavigationTabs.Screen name="index" options={OPTIONS.index}>
              {() => <Text>index scene</Text>}
            </ReactNavigationTabs.Screen>
            <ReactNavigationTabs.Screen
              name="explore"
              options={OPTIONS.explore}
            >
              {() => <Text>explore scene</Text>}
            </ReactNavigationTabs.Screen>
          </ReactNavigationTabs.Navigator>
        </NavigationContainer>
      );
    },
  },
];

beforeEach(() => {
  tabViewProps = {};
});

describe.each(adapters)('$name', ({ render: renderAdapter }) => {
  const routeNamed = (name: string) =>
    tabViewProps.navigationState.routes.find(
      (it: { name: string }) => it.name === name
    );

  it('drives the shared navigator', async () => {
    await renderAdapter();

    expect(
      tabViewProps.navigationState.routes.map((it: { name: string }) => it.name)
    ).toEqual(['index', 'explore']);
    expect(tabViewProps.navigationState.index).toBe(0);
  });

  it('maps screen options onto the native view', async () => {
    await renderAdapter();

    expect(tabViewProps.getLabelText({ route: routeNamed('index') })).toBe(
      'Home'
    );
    expect(tabViewProps.getBadge({ route: routeNamed('index') })).toBe('3');
    expect(
      tabViewProps.getBadge({ route: routeNamed('explore') })
    ).toBeUndefined();
  });

  it('navigates when a tab is pressed', async () => {
    await renderAdapter();

    await act(async () => {
      tabViewProps.onIndexChange(1);
    });

    expect(tabViewProps.navigationState.index).toBe(1);
  });

  it('exposes only the declared screens as tabs', async () => {
    await renderAdapter();

    expect(tabViewProps.navigationState.routes).toHaveLength(2);
  });

  it('does not forward router options to the native view', async () => {
    await renderAdapter();

    expect(tabViewProps).not.toHaveProperty('backBehavior');
  });
});
