import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';
import { StyleSheet, Text, View } from 'react-native';

const Tab = createNativeBottomTabNavigator();

function DarkScreen() {
  return (
    <View testID="lazyDarkScreen" style={styles.darkScreen}>
      <Text style={styles.darkScreenText}>Lazy screen with dark content</Text>
    </View>
  );
}

export default function NativeBottomTabsLazy() {
  return (
    <Tab.Navigator>
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
          lazy: false,
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
        name="Dark"
        component={DarkScreen}
        options={{
          tabBarButtonTestID: 'lazyDarkTab',
          tabBarIcon: () => require('../../assets/icons/chat_dark.png'),
        }}
      />
    </Tab.Navigator>
  );
}

const styles = StyleSheet.create({
  darkScreen: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#1E2D2F',
  },
  darkScreenText: {
    color: '#F7DBA7',
    fontSize: 24,
  },
});
