import type { StandardNavigator } from 'standard-navigation';

import { nativeBottomTabsNavigator } from '../index';
import type {
  NativeBottomTabNavigationOptions,
  NativeBottomTabsEventMap,
  NativeBottomTabsNavigatorProps,
} from '../types';

jest.mock('react-native-bottom-tabs', () => ({
  __esModule: true,
  default: () => null,
}));

const conformsToTheContract: StandardNavigator<
  NativeBottomTabNavigationOptions,
  NativeBottomTabsEventMap,
  NativeBottomTabsNavigatorProps
> = nativeBottomTabsNavigator;

it('declares a navigator matching the published standard-navigation contract', () => {
  expect(conformsToTheContract.type).toBe('standard');
  expect(conformsToTheContract.version).toBe(1);
  expect(typeof conformsToTheContract.NavigatorContent).toBe('function');
});
