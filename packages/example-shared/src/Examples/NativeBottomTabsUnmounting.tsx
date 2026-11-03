import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';
import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';
import React from 'react';
import { Alert } from 'react-native';

const Tab = createNativeBottomTabNavigator();

function NativeBottomTabsUnmounting() {
  const [isTabMounted, setIsTabMounted] = React.useState(true);

  React.useEffect(() => {
    const id = setTimeout(() => {
      setIsTabMounted(false);
      Alert.alert('Tab is unmounted');
    }, 1000);

    return () => clearTimeout(id);
  }, []);
  return (
    <Tab.Navigator initialRouteName="Chat" labeled={true}>
      <Tab.Screen
        name="Article"
        component={Article}
        options={{
          tabBarButtonTestID: 'articleTestID',
          tabBarBadge: '10',
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
        options={{
          tabBarIcon: () => require('../../assets/icons/person_dark.png'),
        }}
      />
      {isTabMounted && (
        <Tab.Screen
          name="Chat"
          component={Chat}
          options={{
            tabBarIcon: () => require('../../assets/icons/chat_dark.png'),
          }}
        />
      )}
    </Tab.Navigator>
  );
}

export default NativeBottomTabsUnmounting;
