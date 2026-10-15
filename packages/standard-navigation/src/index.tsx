import type { StandardNavigator } from 'standard-navigation';

import NativeBottomTabsContent from './NativeBottomTabsContent';
import type {
  NativeBottomTabNavigationOptions,
  NativeBottomTabsEventMap,
  NativeBottomTabsNavigatorProps,
} from './types';

export const nativeBottomTabsNavigator = {
  type: 'standard',
  version: 1,
  NavigatorContent: NativeBottomTabsContent,
} as const satisfies StandardNavigator<
  NativeBottomTabNavigationOptions,
  NativeBottomTabsEventMap,
  NativeBottomTabsNavigatorProps
>;

export { default as NativeBottomTabsContent } from './NativeBottomTabsContent';

export type {
  NativeBottomTabNavigationOptions,
  NativeBottomTabsContentProps,
  NativeBottomTabsDescriptorMap,
  NativeBottomTabsEventMap,
  NativeBottomTabsInferenceCarrier,
  NativeBottomTabsNavigatorProps,
  NativeBottomTabsTabBarProps,
  NavigatorActions,
  NavigatorArgs,
  NavigatorDescriptor,
  NavigatorEmitter,
  NavigatorRoute,
  NavigatorState,
} from './types';
