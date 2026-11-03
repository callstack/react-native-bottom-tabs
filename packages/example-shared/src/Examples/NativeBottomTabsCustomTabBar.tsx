import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';
import {
  createNativeBottomTabNavigator,
  type BottomTabBarProps,
} from '@bottom-tabs/react-navigation';
import { BottomTabBar } from '@react-navigation/bottom-tabs';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

const Tab = createNativeBottomTabNavigator();

const CustomTabBar = (props: BottomTabBarProps) => {
  const insets = useSafeAreaInsets();
  // @ts-ignore Typescript thinks that props don't match but they are actually the same under the hood
  return <BottomTabBar insets={insets} {...props} />;
};

function NativeBottomTabsCustomTabBar() {
  return (
    <Tab.Navigator tabBar={CustomTabBar}>
      <Tab.Screen name="Article" component={Article} />
      <Tab.Screen name="Albums" component={Albums} />
      <Tab.Screen name="Contacts" component={Contacts} />
      <Tab.Screen
        name="Chat"
        component={Chat}
        options={{
          tabBarBadge: '3',
        }}
      />
    </Tab.Navigator>
  );
}

export default NativeBottomTabsCustomTabBar;
