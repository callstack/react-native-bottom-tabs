import { createNativeBottomTabNavigator } from '@bottom-tabs/react-navigation';
import {
  KeyboardAvoidingView,
  Platform,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { useBottomTabBarHeight } from 'react-native-bottom-tabs';

const Tab = createNativeBottomTabNavigator();

function HomeScreen() {
  const tabBarHeight = useBottomTabBarHeight();
  const hasLiquidGlassBottomTabBar =
    Platform.OS === 'ios' &&
    !Platform.isPad &&
    !Platform.isTV &&
    parseFloat(String(Platform.Version)) >= 26;

  return (
    <View style={styles.container}>
      <KeyboardAvoidingView
        behavior="padding"
        style={[
          styles.keyboardAvoidingView,
          hasLiquidGlassBottomTabBar && { marginBottom: tabBarHeight },
        ]}
      >
        <View style={styles.content}>
          <Text style={styles.title}>KeyboardAvoidingView + Bottom Tabs</Text>
          <View style={styles.spacer} />
          <TextInput
            testID="keyboard-avoiding-input"
            style={styles.input}
            placeholder="Tap here to open keyboard"
            placeholderTextColor="#666"
          />
        </View>
      </KeyboardAvoidingView>
    </View>
  );
}

function SettingsScreen() {
  return (
    <View style={styles.container}>
      <Text>Settings</Text>
    </View>
  );
}

export default function KeyboardAvoidingViewExample() {
  return (
    <Tab.Navigator initialRouteName="Home">
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarButtonTestID: 'keyboard-avoiding-home-tab',
          tabBarIcon: () => require('../../assets/icons/article_dark.png'),
        }}
      />
      <Tab.Screen
        name="Settings"
        component={SettingsScreen}
        options={{
          tabBarButtonTestID: 'keyboard-avoiding-settings-tab',
          tabBarIcon: () => require('../../assets/icons/grid_dark.png'),
        }}
      />
    </Tab.Navigator>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  keyboardAvoidingView: {
    flex: 1,
  },
  content: {
    flex: 1,
    padding: 20,
    justifyContent: 'flex-end',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  spacer: {
    flex: 1,
  },
  input: {
    borderWidth: 1,
    borderColor: '#555',
    borderRadius: 8,
    padding: 15,
    fontSize: 16,
  },
});
