import TabView from 'react-native-bottom-tabs';
import { useState } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

const routes = [
  {
    key: 'article',
    title: 'Article',
    focusedIcon: require('../../assets/icons/article_dark.png'),
  },
  {
    key: 'albums',
    title: 'Albums',
    focusedIcon: require('../../assets/icons/grid_dark.png'),
  },
  {
    key: 'contacts',
    title: 'Contacts',
    focusedIcon: require('../../assets/icons/person_dark.png'),
  },
];

export default function CustomTabBar() {
  const [index, setIndex] = useState(0);

  return (
    <TabView
      sidebarAdaptable
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={({ route }) => (
        <View style={styles.screen}>
          <Text style={styles.title}>{route.title}</Text>
        </View>
      )}
      tabBar={() => (
        <View style={styles.customTabBar}>
          {routes.map((route, routeIndex) => {
            const focused = routeIndex === index;

            return (
              <Pressable
                key={route.key}
                style={[
                  styles.customTabBarItem,
                  focused && styles.customTabBarItemFocused,
                ]}
                onPress={() => setIndex(routeIndex)}
              >
                <Text
                  style={[
                    styles.customTabBarLabel,
                    focused && styles.customTabBarLabelFocused,
                  ]}
                >
                  {route.title}
                </Text>
              </Pressable>
            );
          })}
        </View>
      )}
    />
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
  },
  customTabBar: {
    flexDirection: 'row',
    gap: 8,
    paddingHorizontal: 12,
    paddingTop: 10,
    paddingBottom: 18,
    backgroundColor: '#24292f',
  },
  customTabBarItem: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 44,
    borderRadius: 6,
    backgroundColor: '#3b434c',
  },
  customTabBarItemFocused: {
    backgroundColor: '#ffffff',
  },
  customTabBarLabel: {
    color: '#ffffff',
    fontWeight: '600',
  },
  customTabBarLabelFocused: {
    color: '#24292f',
  },
});
