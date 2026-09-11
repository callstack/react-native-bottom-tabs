import { NativeBottomTabsContent } from '@bottom-tabs/navigation';
import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';
import { TabRouter, unstable_createStandardRouterNavigator } from 'expo-router';

export const ExpoRouterTabs = unstable_createStandardRouterNavigator(
  NativeBottomTabsContent,
  TabRouter
);

export const ReactNavigationTabs = createNativeBottomTabNavigator();
