import NativeBottomTabsContent from './NativeBottomTabsContent';

export const nativeBottomTabsNavigator = {
  type: 'standard',
  version: 1,
  NavigatorContent: NativeBottomTabsContent,
} as const;

export { default as NativeBottomTabsContent } from './NativeBottomTabsContent';

export type {
  NativeBottomTabNavigationOptions,
  NativeBottomTabsContentProps,
  NativeBottomTabsDescriptorMap,
  NativeBottomTabsEventMap,
  NativeBottomTabsNavigatorProps,
  NativeBottomTabsTabBarProps,
  NavigatorActions,
  NavigatorArgs,
  NavigatorDescriptor,
  NavigatorEmitter,
  NavigatorRoute,
  NavigatorState,
} from './types';
