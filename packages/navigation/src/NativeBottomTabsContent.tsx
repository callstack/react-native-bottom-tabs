import TabView from 'react-native-bottom-tabs';

import type { NativeBottomTabsContentProps, NavigatorRoute } from './types';

export default function NativeBottomTabsContent({
  state,
  descriptors,
  actions,
  emitter,
  tabBar,
  backBehavior: _backBehavior,
  ...rest
}: NativeBottomTabsContentProps & { backBehavior?: unknown }) {
  if (state.routes.length === 0) {
    return null;
  }

  const optionsFor = (route: NavigatorRoute) => descriptors[route.key]?.options;

  return (
    <TabView
      {...rest}
      navigationState={state}
      renderScene={({ route }) => descriptors[route.key]?.render()}
      getActiveTintColor={({ route }) =>
        optionsFor(route)?.tabBarActiveTintColor
      }
      getLabelText={({ route }) => {
        const options = optionsFor(route);

        return options?.tabBarLabel !== undefined
          ? options.tabBarLabel
          : options?.title !== undefined
            ? options.title
            : route.name;
      }}
      getBadge={({ route }) => optionsFor(route)?.tabBarBadge}
      getBadgeBackgroundColor={({ route }) =>
        optionsFor(route)?.tabBarBadgeBackgroundColor
      }
      getBadgeTextColor={({ route }) => optionsFor(route)?.tabBarBadgeTextColor}
      getHidden={({ route }) => optionsFor(route)?.tabBarItemHidden === true}
      getTestID={({ route }) => optionsFor(route)?.tabBarButtonTestID}
      getRole={({ route }) => optionsFor(route)?.role}
      getIconRenderingMode={({ route }) =>
        optionsFor(route)?.tabBarIconRenderingMode
      }
      tabBar={
        tabBar
          ? () => tabBar({ state, descriptors, actions, emitter })
          : undefined
      }
      getIcon={({ route, focused }) => {
        const tabBarIcon = optionsFor(route)?.tabBarIcon;

        return tabBarIcon ? tabBarIcon({ focused }) : null;
      }}
      getLazy={({ route }) => optionsFor(route)?.lazy ?? true}
      getFreezeOnBlur={({ route }) => optionsFor(route)?.freezeOnBlur}
      getSceneStyle={({ route }) => optionsFor(route)?.sceneStyle}
      getPreventsDefault={({ route }) => optionsFor(route)?.preventsDefault}
      onTabLongPress={(index) => {
        const route = state.routes[index];

        if (!route) {
          return;
        }

        emitter.emit({ type: 'tabLongPress', target: route.key });
      }}
      onIndexChange={(index) => {
        const focused = index === state.index;
        const route = state.routes[index];

        if (!route) {
          return;
        }

        const event = emitter.emit({
          type: 'tabPress',
          target: route.key,
          canPreventDefault: true,
        });

        if (
          focused ||
          event.defaultPrevented ||
          optionsFor(route)?.preventsDefault
        ) {
          return;
        }

        actions.navigate(route.name, route.params);
      }}
    />
  );
}
