import { nativeBottomTabsNavigator } from '@bottom-tabs/navigation';
import {
  createStandardNavigationFactories,
  type NavigatorTypeBagBase,
  type ParamListBase,
  type StaticConfig,
  type TabNavigationState,
  TabRouter,
  type TypedNavigator,
  useTheme,
} from '@react-navigation/native';

import type {
  NativeBottomTabNavigationEventMap,
  NativeBottomTabNavigationOptions,
  NativeBottomTabNavigationProp,
} from '../types';
import mixColors from '../mixColors';

const { createNavigator } = createStandardNavigationFactories(
  nativeBottomTabsNavigator,
  TabRouter,
  ({ navigation }) => {
    const { colors } = useTheme();

    return {
      defaultTintColors: {
        active: colors.primary,
        inactive: mixColors(colors.text, colors.card, 0.5),
      },
      extraTabBarProps: { navigation },
    };
  }
);

export default function createNativeBottomTabNavigator<
  const ParamList extends ParamListBase,
  const NavigatorID extends string | undefined = undefined,
  const TypeBag extends NavigatorTypeBagBase = {
    ParamList: ParamList;
    NavigatorID: NavigatorID;
    State: TabNavigationState<ParamList>;
    ScreenOptions: NativeBottomTabNavigationOptions;
    EventMap: NativeBottomTabNavigationEventMap;
    NavigationList: {
      [RouteName in keyof ParamList]: NativeBottomTabNavigationProp<
        ParamList,
        RouteName,
        NavigatorID
      >;
    };
    Navigator: React.ComponentType<any>;
  },
  const Config extends StaticConfig<TypeBag> = StaticConfig<TypeBag>,
>(config?: Config): TypedNavigator<TypeBag, Config> {
  return createNavigator(config as never) as unknown as TypedNavigator<
    TypeBag,
    Config
  >;
}
