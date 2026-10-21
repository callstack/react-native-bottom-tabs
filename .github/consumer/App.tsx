// Copied over a fresh React Native Community CLI app by the `consumer-cli` CI
// job, which installs the packed tarball instead of the workspace source.
import * as React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import TabView, {
  SceneMap,
  useBottomTabBarHeight,
  type AppleIcon,
} from 'react-native-bottom-tabs';

function HomeScreen() {
  const tabBarHeight = useBottomTabBarHeight();
  return (
    <View style={styles.screen}>
      <Text>Tab bar height: {tabBarHeight}</Text>
    </View>
  );
}

function SettingsScreen() {
  return (
    <View style={styles.screen}>
      <Text>Settings</Text>
    </View>
  );
}

const renderScene = SceneMap({
  home: HomeScreen,
  settings: SettingsScreen,
});

const settingsIcon: AppleIcon = { sfSymbol: 'gear' };

export default function App() {
  const [index, setIndex] = React.useState(0);
  const [routes] = React.useState([
    { key: 'home', title: 'Home', focusedIcon: { sfSymbol: 'house' } },
    {
      key: 'settings',
      title: 'Settings',
      focusedIcon: settingsIcon,
      badge: '3',
    },
  ]);

  return (
    <TabView
      navigationState={{ index, routes }}
      renderScene={renderScene}
      onIndexChange={setIndex}
      labeled
      minimizeBehavior="onScrollDown"
    />
  );
}

const styles = StyleSheet.create({
  screen: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});
