import { Platform } from 'react-native';
import { TabRouter, unstable_createStandardRouterNavigator } from 'expo-router';
import { NativeBottomTabsContent } from '@bottom-tabs/standard-navigation';

import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

const Tabs = unstable_createStandardRouterNavigator(
  NativeBottomTabsContent,
  TabRouter
);

export default function TabLayout() {
  const colorScheme = useColorScheme();
  const colorTheme = Colors[colorScheme];

  return (
    <Tabs
      tabBarActiveTintColor={colorTheme.tabIconSelected}
      tabBarInactiveTintColor={colorTheme.tabIconDefault}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: () =>
            Platform.OS === 'ios'
              ? { sfSymbol: 'house.fill' }
              : require('@/assets/icons/house.png'),
        }}
      />
      <Tabs.Screen
        name="explore"
        options={{
          title: 'Explore',
          tabBarIcon: () =>
            Platform.OS === 'ios'
              ? { sfSymbol: 'paperplane.fill' }
              : require('@/assets/icons/send.png'),
        }}
      />
    </Tabs>
  );
}
