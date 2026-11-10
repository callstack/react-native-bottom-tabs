import TabView, { type TabBarColorScheme } from 'react-native-bottom-tabs';
import { useState } from 'react';
import {
  Button,
  StyleSheet,
  Text,
  useColorScheme,
  View,
} from 'react-native';

const schemes: TabBarColorScheme[] = ['inherit', 'light', 'dark'];

const screens = [
  { name: 'light', backgroundColor: '#fff', color: '#000' },
  { name: 'gray', backgroundColor: '#808080', color: '#000' },
  { name: 'dark', backgroundColor: '#111', color: '#fff' },
] as const;

const routes = [
  {
    key: 'article',
    title: 'Article',
    focusedIcon: require('../../assets/icons/article_dark.png'),
    testID: 'articleTestID',
  },
  {
    key: 'albums',
    title: 'Albums',
    focusedIcon: require('../../assets/icons/grid_dark.png'),
    badge: '5',
    testID: 'albumsTestID',
  },
  {
    key: 'contacts',
    title: 'Contacts',
    focusedIcon: require('../../assets/icons/person_dark.png'),
    testID: 'contactsTestID',
  },
];

export default function TabBarColorSchemeExample() {
  const [index, setIndex] = useState(0);
  const [scheme, setScheme] = useState<TabBarColorScheme>('inherit');
  const [screenIndex, setScreenIndex] = useState(0);
  const systemScheme = useColorScheme();
  const screen = screens[screenIndex % screens.length]!;
  const textColor = screen.color;

  return (
    <TabView
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      tabBarColorScheme={scheme}
      renderScene={() => (
        <View
          style={[styles.scene, { backgroundColor: screen.backgroundColor }]}
        >
          <Text style={{ color: textColor }}>System: {systemScheme}</Text>
          <Text testID="currentScheme" style={{ color: textColor }}>
            tabBarColorScheme: {scheme}
          </Text>
          {schemes.map((value) => (
            <Button
              key={value}
              testID={`scheme-${value}`}
              title={value}
              onPress={() => setScheme(value)}
            />
          ))}
          <Button
            testID="toggle-scene"
            title={`Screen: ${screen.name}`}
            onPress={() => setScreenIndex(screenIndex + 1)}
          />
        </View>
      )}
    />
  );
}

const styles = StyleSheet.create({
  scene: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 12,
  },
});
