import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';
import { useState } from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';

const Tab = createNativeBottomTabNavigator();

type TabBarHiddenScreenProps = {
  title: string;
  tabBarHidden: boolean;
  onToggleTabBarHidden: () => void;
};

function TabBarHiddenScreen({
  title,
  tabBarHidden,
  onToggleTabBarHidden,
}: TabBarHiddenScreenProps) {
  return (
    <View style={styles.screen}>
      <Text style={styles.title}>{title}</Text>
      <Button
        title={`${tabBarHidden ? 'Show' : 'Hide'} Tab Bar`}
        onPress={onToggleTabBarHidden}
      />
    </View>
  );
}

export default function NativeBottomTabsTabBarHidden() {
  const [tabBarHidden, setTabBarHidden] = useState(false);
  const toggleTabBarHidden = () => setTabBarHidden((value) => !value);

  return (
    <Tab.Navigator sidebarAdaptable tabBarHidden={tabBarHidden}>
      <Tab.Screen
        name="Article"
        options={{
          tabBarIcon: () => require('../../assets/icons/article_dark.png'),
        }}
      >
        {() => (
          <TabBarHiddenScreen
            title="Article"
            tabBarHidden={tabBarHidden}
            onToggleTabBarHidden={toggleTabBarHidden}
          />
        )}
      </Tab.Screen>
      <Tab.Screen
        name="Albums"
        options={{
          tabBarIcon: () => require('../../assets/icons/grid_dark.png'),
        }}
      >
        {() => (
          <TabBarHiddenScreen
            title="Albums"
            tabBarHidden={tabBarHidden}
            onToggleTabBarHidden={toggleTabBarHidden}
          />
        )}
      </Tab.Screen>
      <Tab.Screen
        name="Contacts"
        options={{
          tabBarIcon: () => require('../../assets/icons/person_dark.png'),
        }}
      >
        {() => (
          <TabBarHiddenScreen
            title="Contacts"
            tabBarHidden={tabBarHidden}
            onToggleTabBarHidden={toggleTabBarHidden}
          />
        )}
      </Tab.Screen>
    </Tab.Navigator>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 16,
    padding: 24,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
  },
});
