import { useState } from 'react';
import { Button, StyleSheet, Switch, Text, View } from 'react-native';
import TabView, { SceneMap } from 'react-native-bottom-tabs';
import type { TabRole } from 'react-native-bottom-tabs';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';

const renderScene = SceneMap({
  article: Article,
  albums: Albums,
  role: Contacts,
});

export default function Roles() {
  const [role, setRole] = useState<TabRole>('search');
  const [bakedTintColors, setBakedTintColors] = useState(false);

  return (
    <View style={styles.container}>
      <View style={styles.controls}>
        <View style={styles.row}>
          <Button
            title="Search"
            disabled={role === 'search'}
            onPress={() => setRole('search')}
          />
          <Button
            title="Prominent"
            disabled={role === 'prominent'}
            onPress={() => setRole('prominent')}
          />
        </View>
        <Text>
          {role === 'search'
            ? 'Search role (iOS 18+). May receive prominent styling when no tab has the prominent role.'
            : 'Prominent role (iOS 27+). Emphasizes the Contacts tab; falls back to an ordinary tab on older iOS versions.'}
        </Text>
        <View style={styles.row}>
          <Text>Experimental baked tint colors</Text>
          <Switch
            accessibilityLabel="Experimental baked tint colors"
            value={bakedTintColors}
            onValueChange={setBakedTintColors}
          />
        </View>
      </View>
      <RoleTabs key={role} role={role} bakedTintColors={bakedTintColors} />
    </View>
  );
}

function RoleTabs({
  role,
  bakedTintColors,
}: {
  role: TabRole;
  bakedTintColors: boolean;
}) {
  const [index, setIndex] = useState(0);
  const [routes] = useState([
    {
      key: 'article',
      title: 'Article',
      focusedIcon: { sfSymbol: 'doc.text' },
    },
    {
      key: 'albums',
      title: 'Albums',
      focusedIcon: { sfSymbol: 'square.grid.2x2' },
    },
    {
      key: 'role',
      title: role === 'search' ? 'Search' : 'Contacts',
      focusedIcon: {
        sfSymbol: role === 'search' ? 'magnifyingglass' : 'person.crop.circle',
      },
      role,
      testID: `roles-${role}-tab`,
    },
  ]);

  return (
    <TabView
      navigationState={{ index, routes }}
      onIndexChange={setIndex}
      renderScene={renderScene}
      labeled
      tabBarActiveTintColor="red"
      tabBarInactiveTintColor="orange"
      experimental_bakedTintColors={bakedTintColors}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  controls: {
    padding: 12,
    gap: 12,
  },
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
});
