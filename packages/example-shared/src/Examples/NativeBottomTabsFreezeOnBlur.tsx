import * as React from 'react';
import { Platform, StyleSheet, Text, View } from 'react-native';
import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';

const store = new Set<Dispatch>();

type Dispatch = (value: number) => void;

function useValue() {
  const [value, setValue] = React.useState<number>(0);

  React.useEffect(() => {
    const dispatch = (value: number) => {
      setValue(value);
    };
    store.add(dispatch);
    return () => {
      store.delete(dispatch);
    };
  }, [setValue]);

  return value;
}

function HomeScreen() {
  return (
    <View style={styles.screenContainer}>
      <Text>Home!</Text>
    </View>
  );
}

function DetailsScreen(props: any) {
  const value = useValue();
  const screenName = props?.route?.params?.screenName;
  // only 1 'render' should appear at the time
  console.log(`${Platform.OS} Details Screen render ${value} ${screenName}`);
  return (
    <View style={styles.screenContainer}>
      <Text>Details!</Text>
      <Text style={{ alignSelf: 'center' }}>
        Details Screen {value} {screenName ? screenName : ''}{' '}
      </Text>
    </View>
  );
}
const Tab = createNativeBottomTabNavigator();

export default function NativeBottomTabsFreezeOnBlur() {
  React.useEffect(() => {
    let timer = 0;
    const interval = setInterval(() => {
      timer = timer + 1;
      store.forEach((dispatch) => dispatch(timer));
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <Tab.Navigator
      screenOptions={{
        freezeOnBlur: true,
      }}
    >
      <Tab.Screen
        name="Article"
        component={HomeScreen}
        initialParams={{
          screenName: 'Article',
        }}
        options={{
          tabBarIcon: () => require('../../assets/icons/article_dark.png'),
        }}
      />
      <Tab.Screen
        name="Albums"
        component={DetailsScreen}
        initialParams={{
          screenName: 'Albums',
        }}
        options={{
          tabBarIcon: () => require('../../assets/icons/grid_dark.png'),
        }}
      />
      <Tab.Screen
        name="Contact"
        component={DetailsScreen}
        initialParams={{
          screenName: 'Contact',
        }}
        options={{
          tabBarIcon: () => require('../../assets/icons/person_dark.png'),
        }}
      />
      <Tab.Screen
        name="Chat"
        component={DetailsScreen}
        initialParams={{
          screenName: 'Chat',
        }}
        options={{
          tabBarIcon: () => require('../../assets/icons/chat_dark.png'),
        }}
      />
    </Tab.Navigator>
  );
}

const styles = StyleSheet.create({
  screenContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
});
