import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';

const Tab = createNativeBottomTabNavigator();

export default function NativeBottomTabsOriginalIcons() {
  return (
    <Tab.Navigator initialRouteName="Tinted" labeled>
      <Tab.Screen
        name="Tinted"
        component={Article}
        options={{
          tabBarIcon: () => require('../../assets/avatar-4.png'),
        }}
      />
      <Tab.Screen
        name="Avatar"
        component={Contacts}
        options={{
          tabBarIcon: () => require('../../assets/avatar-1.png'),
          tabBarIconRenderingMode: 'original',
        }}
      />
      <Tab.Screen
        name="Album"
        component={Albums}
        options={{
          tabBarIcon: ({ focused }) =>
            focused
              ? require('../../assets/avatar-4.png')
              : require('../../assets/avatar-3.png'),
          tabBarIconRenderingMode: 'original',
        }}
      />
      <Tab.Screen
        name="Chat"
        component={Chat}
        options={{
          tabBarIcon: () => require('../../assets/avatar-4.png'),
          tabBarIconRenderingMode: 'original',
        }}
      />
    </Tab.Navigator>
  );
}
