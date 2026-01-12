import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';
import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';
import { Platform } from 'react-native';
import { useState } from 'react';

const Tab = createNativeBottomTabNavigator();

function NativeBottomTabs() {
  const [label, setLabel] = useState('Article');
  return (
    <Tab.Navigator
      initialRouteName="Chat"
      labeled={true}
      hapticFeedbackEnabled={false}
      layoutDirection="ltr"
      tabBarInactiveTintColor="#C57B57"
      tabBarActiveTintColor="#F7DBA7"
      tabBarStyle={{
        backgroundColor: '#1E2D2F',
      }}
      rippleColor="#F7DBA7"
      tabLabelStyle={{
        fontFamily: 'Avenir',
        fontSize: 15,
      }}
      activeIndicatorColor="#041F1E"
      screenListeners={{
        tabLongPress: (data) => {
          console.log(
            `${Platform.OS}: Long press detected on tab with key ${data.target} at the navigator level.`
          );
        },
      }}
    >
      <Tab.Screen
        name="Article"
        component={Article}
        listeners={{
          tabLongPress: (data) => {
            console.log(
              `${Platform.OS}: Long press detected on tab with key ${data.target} at the screen level.`
            );
            setLabel('New Article');
          },
        }}
        options={{
          tabBarButtonTestID: 'articleTestID',
          tabBarBadge: '10',
          tabBarLabel: label,
          tabBarIcon: ({ focused }) =>
            focused
              ? require('../../assets/icons/person_dark.png')
              : require('../../assets/icons/article_dark.png'),
        }}
      />
      <Tab.Screen
        name="Albums"
        component={Albums}
        options={{
          tabBarIcon: () => require('../../assets/icons/grid_dark.png'),
        }}
      />
      <Tab.Screen
        name="Contacts"
        component={Contacts}
        listeners={{
          tabPress: () => {
            console.log('Contacts tab press prevented');
          },
        }}
        options={{
          tabBarIcon: () => require('../../assets/icons/person_dark.png'),
          tabBarActiveTintColor: 'yellow',
          preventsDefault: true,
        }}
      />
      <Tab.Screen
        name="Chat"
        component={Chat}
        listeners={{
          tabPress: () => {
            console.log('Chat tab pressed');
          },
        }}
        options={{
          tabBarIcon: () => require('../../assets/icons/chat_dark.png'),
          tabBarActiveTintColor: 'white',
        }}
      />
    </Tab.Navigator>
  );
}

export default NativeBottomTabs;
