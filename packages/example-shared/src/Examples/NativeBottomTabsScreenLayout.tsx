import * as React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';
import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';

const Tab = createNativeBottomTabNavigator();

function ScreenLayout({
  children,
  route,
}: {
  children: React.ReactNode;
  route: { name: string };
}) {
  return (
    <View style={styles.container}>
      <View style={styles.banner}>
        <Text style={styles.bannerTitle}>screenLayout active</Text>
        <Text style={styles.bannerSubtitle}>{route.name}</Text>
      </View>
      <View style={styles.content}>{children}</View>
    </View>
  );
}

export default function NativeBottomTabsScreenLayout() {
  return (
    <Tab.Navigator screenLayout={ScreenLayout}>
      <Tab.Screen
        name="Article"
        component={Article}
        options={{
          tabBarIcon: () => require('../../assets/icons/article_dark.png'),
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
      <Tab.Screen
        name="Chat"
        component={Chat}
        options={{
          tabBarIcon: () => require('../../assets/icons/chat_dark.png'),
        }}
      />
    </Tab.Navigator>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F3F0E8',
  },
  banner: {
    paddingHorizontal: 16,
    paddingVertical: 12,
    backgroundColor: '#1E2D2F',
  },
  bannerTitle: {
    color: '#F7DBA7',
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  bannerSubtitle: {
    marginTop: 4,
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  content: {
    flex: 1,
  },
});
