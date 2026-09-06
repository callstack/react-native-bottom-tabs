import * as React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';
import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

const Tabs = createNativeBottomTabNavigator();
const TVPressable = Pressable as React.ComponentType<
  React.ComponentProps<typeof Pressable> & {
    tvParallaxProperties?: { magnification?: number };
  }
>;

function WatchingScreen() {
  const [focusedIndex, setFocusedIndex] = React.useState<number | null>(null);

  return (
    <View style={styles.screen}>
      <Text accessibilityLabel="Focus status" style={styles.status}>
        Focused: {focusedIndex === null ? 'none' : `Button ${focusedIndex}`}
      </Text>
      <ScrollView contentContainerStyle={styles.content}>
        {Array.from({ length: 20 }, (_, index) => (
          <TVPressable
            accessibilityLabel={`Button ${index}`}
            key={index}
            onFocus={() => setFocusedIndex(index)}
            style={[
              styles.button,
              focusedIndex === index && styles.focusedButton,
            ]}
            testID={`button-${index}`}
            tvParallaxProperties={{ magnification: 1.1 }}
          >
            <Text
              style={[
                styles.buttonText,
                focusedIndex === index && styles.focusedButtonText,
              ]}
            >
              Button {index}
            </Text>
          </TVPressable>
        ))}
      </ScrollView>
    </View>
  );
}

function SearchScreen() {
  return (
    <View style={styles.center}>
      <Pressable accessibilityLabel="Search action" style={styles.button}>
        <Text style={styles.buttonText}>Search action</Text>
      </Pressable>
    </View>
  );
}

function NewScreen() {
  return (
    <View style={styles.center}>
      <Pressable accessibilityLabel="New action" style={styles.button}>
        <Text style={styles.buttonText}>New action</Text>
      </Pressable>
    </View>
  );
}

function App() {
  return (
    <NavigationContainer>
      <Tabs.Navigator
        initialRouteName="Watching"
        sidebarAdaptable
        screenOptions={{ freezeOnBlur: true }}
      >
        <Tabs.Screen
          component={WatchingScreen}
          name="Watching"
          options={{
            title: 'Watching',
            tabBarIcon: () => ({ sfSymbol: 'star.fill' }),
          }}
        />
        <Tabs.Screen
          component={SearchScreen}
          name="Search"
          options={{
            title: 'Search',
            tabBarIcon: () => ({ sfSymbol: 'magnifyingglass' }),
          }}
        />
        <Tabs.Screen
          component={NewScreen}
          name="New"
          options={{
            title: 'New',
            tabBarIcon: () => ({ sfSymbol: 'plus' }),
          }}
        />
      </Tabs.Navigator>
    </NavigationContainer>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#101114',
  },
  status: {
    color: 'white',
    fontSize: 24,
    marginHorizontal: 80,
    marginTop: 30,
  },
  content: {
    gap: 24,
    padding: 80,
  },
  button: {
    alignItems: 'center',
    backgroundColor: '#30343b',
    borderRadius: 10,
    minHeight: 64,
    justifyContent: 'center',
    paddingHorizontal: 30,
  },
  focusedButton: {
    backgroundColor: '#f4f4f4',
    transform: [{ scale: 1.04 }],
  },
  buttonText: {
    color: '#f4f4f4',
    fontSize: 22,
    fontWeight: '600',
  },
  focusedButtonText: {
    color: '#111217',
  },
  center: {
    alignItems: 'center',
    backgroundColor: '#101114',
    flex: 1,
    justifyContent: 'center',
    padding: 80,
  },
});

export default App;
