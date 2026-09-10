import { nativeBottomTabsNavigator } from '@bottom-tabs/navigation';
import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';
import { TabRouter, unstable_integrateWithRouter } from 'expo-router';

export const ExpoRouterTabs = unstable_integrateWithRouter(
  nativeBottomTabsNavigator,
  TabRouter
);

export const ReactNavigationTabs = createNativeBottomTabNavigator();
