import TabView from 'react-native-bottom-tabs';
import { useState } from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';

const routes = [
  {
    key: 'article',
    title: 'Article',
    focusedIcon: require('../../assets/icons/article_dark.png'),
  },
  {
    key: 'albums',
    title: 'Albums',
    focusedIcon: require('../../assets/icons/grid_dark.png'),
  },
  {
    key: 'contacts',
    title: 'Contacts',
    focusedIcon: require('../../assets/icons/person_dark.png'),
  },
];

type TabBarHiddenScreenProps = {
  title: string;
  tabBarHidden: boolean;
  onToggleTabBarHidden: () => void;
};

function TabBarHiddenScreen({
  title,
  tabBarHidden,
  onToggleTabBarHidden,
}: TabBarHiddenScreenProps) {
  return (
    <View style={styles.screen}>
      <Text style={styles.title}>{title}</Text>
      <Button
        title={`${tabBarHidden ? 'Show' : 'Hide'} Tab Bar`}
        onPress={onToggleTabBarHidden}
      />
    </View>
  );
}

export default function TabBarHidden() {
  const [index, setIndex] = useState(0);
  const [tabBarHidden, setTabBarHidden] = useState(false);

  return (
    <TabView
      sidebarAdaptable
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={({ route }) => (
        <TabBarHiddenScreen
          title={route.title}
          tabBarHidden={tabBarHidden}
          onToggleTabBarHidden={() => setTabBarHidden((value) => !value)}
        />
      )}
      tabBarHidden={tabBarHidden}
    />
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    gap: 16,
    padding: 24,
  },
  title: {
    fontSize: 24,
    fontWeight: '600',
  },
});
