import { Platform } from 'react-native';
import { withLayoutContext } from 'expo-router';
import {
  createNativeBottomTabNavigator,
  NativeBottomTabNavigationOptions,
  NativeBottomTabNavigationEventMap,
} from '@bottom-tabs/react-navigation';
import { ParamListBase, TabNavigationState } from '@react-navigation/native';

import { Colors } from '@/constants/Colors';
import { useColorScheme } from '@/hooks/useColorScheme';

const BottomTabNavigator = createNativeBottomTabNavigator().Navigator;

const Tabs = withLayoutContext<
  NativeBottomTabNavigationOptions,
  typeof BottomTabNavigator,
  TabNavigationState<ParamListBase>,
  NativeBottomTabNavigationEventMap
>(BottomTabNavigator);

export default function TabLayout() {
  const colorScheme = useColorScheme() ?? 'light';
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
