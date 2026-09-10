import { NativeBottomTabsContent } from '@bottom-tabs/navigation';
import {
  CommonActions,
  type ParamListBase,
  type TabNavigationState,
} from '@react-navigation/native';

import type {
  NativeBottomTabDescriptorMap,
  NativeBottomTabNavigationConfig,
  NativeBottomTabNavigationHelpers,
} from '../types';

type Props = NativeBottomTabNavigationConfig & {
  state: TabNavigationState<ParamListBase>;
  navigation: NativeBottomTabNavigationHelpers;
  descriptors: NativeBottomTabDescriptorMap;
};

export default function NativeBottomTabView({
  state,
  navigation,
  descriptors,
  tabBar,
  ...rest
}: Props) {
  return (
    <NativeBottomTabsContent
      {...rest}
      state={state}
      descriptors={descriptors}
      actions={{
        navigate: (name, params) =>
          navigation.dispatch({
            ...CommonActions.navigate(name, params),
            target: state.key,
          }),
        back: () => navigation.goBack(),
      }}
      emitter={{ emit: navigation.emit }}
      tabBar={
        tabBar ? () => tabBar({ state, descriptors, navigation }) : undefined
      }
    />
  );
}
