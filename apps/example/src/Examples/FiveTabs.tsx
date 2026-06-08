import TabView from 'react-native-bottom-tabs';
import { useFocusEffect, useNavigation } from '@react-navigation/native';
import {
  createNativeStackNavigator,
  type NativeStackNavigationProp,
} from '@react-navigation/native-stack';
import * as React from 'react';
import { Button, StyleSheet, Text, View, type ColorValue } from 'react-native';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';

interface Props {
  disablePageAnimations?: boolean;
  scrollEdgeAppearance?: 'default' | 'opaque' | 'transparent';
  backgroundColor?: ColorValue;
  translucent?: boolean;
  rippleColor?: ColorValue;
  activeIndicatorColor?: ColorValue;
}

type ReproStackParamList = {
  ReproHome: undefined;
  HiddenTabBar: undefined;
};

const ReproStack = createNativeStackNavigator<ReproStackParamList>();

function ReproHomeScreen() {
  const navigation =
    useNavigation<
      NativeStackNavigationProp<ReproStackParamList, 'ReproHome'>
    >();

  return (
    <View style={styles.centered}>
      <Text style={styles.title}>Five tabs repro</Text>
      <Text style={styles.instructions}>
        Select the Fifth tab once, return here, open the hidden tab bar screen,
        then go back.
      </Text>
      <Button
        title="Open hidden tab bar screen"
        onPress={() => navigation.navigate('HiddenTabBar')}
      />
    </View>
  );
}

function HiddenTabBarScreen({
  setTabBarHidden,
}: {
  setTabBarHidden: (hidden: boolean) => void;
}) {
  const navigation =
    useNavigation<
      NativeStackNavigationProp<ReproStackParamList, 'HiddenTabBar'>
    >();

  useFocusEffect(
    React.useCallback(() => {
      setTabBarHidden(true);

      return () => {
        setTabBarHidden(false);
      };
    }, [setTabBarHidden])
  );

  return (
    <View style={styles.centered}>
      <Text style={styles.title}>Tab bar hidden</Text>
      <Button title="Go back" onPress={() => navigation.goBack()} />
    </View>
  );
}

function ReproStackScreen({
  setTabBarHidden,
}: {
  setTabBarHidden: (hidden: boolean) => void;
}) {
  return (
    <ReproStack.Navigator>
      <ReproStack.Screen name="ReproHome" component={ReproHomeScreen} />
      <ReproStack.Screen name="HiddenTabBar">
        {() => <HiddenTabBarScreen setTabBarHidden={setTabBarHidden} />}
      </ReproStack.Screen>
    </ReproStack.Navigator>
  );
}

export default function FiveTabs({
  disablePageAnimations = false,
  scrollEdgeAppearance = 'default',
  backgroundColor,
  translucent = true,
  rippleColor,
  activeIndicatorColor,
}: Props) {
  const [index, setIndex] = React.useState(0);
  const [tabBarHidden, setTabBarHidden] = React.useState(false);
  const [routes] = React.useState([
    {
      key: 'article',
      title: 'Article',
      focusedIcon: require('../../assets/icons/article_dark.png'),
      unfocusedIcon: require('../../assets/icons/chat_dark.png'),
      badge: '!',
    },
    {
      key: 'albums',
      title: 'Albums',
      focusedIcon: require('../../assets/icons/grid_dark.png'),
      badge: '5',
    },
    {
      key: 'contacts',
      focusedIcon: require('../../assets/icons/person_dark.png'),
      title: 'Contacts',
      badge: ' ',
    },
    {
      key: 'chat',
      focusedIcon: require('../../assets/icons/chat_dark.png'),
      title: 'Chat',
    },
    {
      key: 'fifth',
      focusedIcon: require('../../assets/icons/person_dark.png'),
      title: 'Fifth',
    },
  ]);

  return (
    <TabView
      sidebarAdaptable
      disablePageAnimations={disablePageAnimations}
      scrollEdgeAppearance={scrollEdgeAppearance}
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={({ route }) => {
        switch (route.key) {
          case 'article':
            return <ReproStackScreen setTabBarHidden={setTabBarHidden} />;
          case 'albums':
            return <Albums />;
          case 'contacts':
            return <Contacts />;
          case 'chat':
            return <Chat />;
          case 'fifth':
            return <Article />;
          default:
            return null;
        }
      }}
      tabBarHidden={tabBarHidden}
      tabBarStyle={{ backgroundColor }}
      translucent={translucent}
      rippleColor={rippleColor}
      activeIndicatorColor={activeIndicatorColor}
    />
  );
}

const styles = StyleSheet.create({
  centered: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 16,
    padding: 24,
    backgroundColor: '#fff',
  },
  title: {
    color: '#000',
    fontSize: 20,
    fontWeight: '600',
  },
  instructions: {
    color: '#000',
    fontSize: 16,
    textAlign: 'center',
  },
});
