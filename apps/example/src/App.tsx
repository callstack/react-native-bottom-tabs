import { enableScreens } from 'react-native-screens';
// run this before any screen render(usually in App.js)
enableScreens();

import * as React from 'react';
import {
  StyleSheet,
  Text,
  ScrollView,
  TouchableOpacity,
  Button,
  Alert,
  Platform,
} from 'react-native';
import {
  NavigationContainer,
  useNavigation,
  useNavigationContainerRef,
} from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import JSBottomTabs from './Examples/JSBottomTabs';
import ThreeTabs from './Examples/ThreeTabs';
import FourTabs from './Examples/FourTabs';
import FourTabsRTL from './Examples/FourTabsRTL';
import MaterialBottomTabs from './Examples/MaterialBottomTabs';
import SFSymbols from './Examples/SFSymbols';
import LabeledTabs from './Examples/Labeled';
import NativeBottomTabs from './Examples/NativeBottomTabs';
import TintColorsExample from './Examples/TintColors';
import NativeBottomTabsEmbeddedStacks from './Examples/NativeBottomTabsEmbeddedStacks';
import NativeBottomTabsSVGs from './Examples/NativeBottomTabsSVGs';
import NativeBottomTabsRemoteIcons from './Examples/NativeBottomTabsRemoteIcons';
import NativeBottomTabsUnmounting from './Examples/NativeBottomTabsUnmounting';
import NativeBottomTabsCustomTabBar from './Examples/NativeBottomTabsCustomTabBar';
import NativeBottomTabsFreezeOnBlur from './Examples/NativeBottomTabsFreezeOnBlur';
import BottomAccessoryView from './Examples/BottomAccessoryView';
import { useLogger } from '@react-navigation/devtools';

const HiddenTab = () => {
  return <FourTabs hideOneTab />;
};

const FourTabsRippleColor = () => {
  return <FourTabs rippleColor={'#00ff00'} />;
};

const FourTabsNoAnimations = () => {
  return <FourTabs disablePageAnimations />;
};

const FourTabsTransparentScrollEdgeAppearance = () => {
  return <FourTabs scrollEdgeAppearance="transparent" />;
};

const FourTabsOpaqueScrollEdgeAppearance = () => {
  return <FourTabs scrollEdgeAppearance="opaque" />;
};

const FourTabsWithBackgroundColor = () => {
  return <FourTabs backgroundColor={'#87CEEB'} />;
};

const FourTabsTranslucent = () => {
  return <FourTabs translucent={false} />;
};

const FourTabsActiveIndicatorColor = () => {
  return <FourTabs activeIndicatorColor={'#87CEEB'} />;
};

const UnlabeledTabs = () => {
  return <LabeledTabs showLabels={false} />;
};
const FourTabsRightToLeft = () => {
  return <FourTabsRTL layoutDirection={'rtl'} />;
};

const examples = [
  {
    component: ThreeTabs,
    name: 'Three Tabs',
  },
  { component: FourTabs, name: 'Four Tabs' },
  {
    component: SFSymbols,
    name: 'SF Symbols',
    screenOptions: { headerShown: false },
  },
  { component: LabeledTabs, name: 'Labeled Tabs' },
  { component: UnlabeledTabs, name: 'Unlabeled Tabs' },
  {
    component: NativeBottomTabsEmbeddedStacks,
    name: 'Embedded stacks',
    screenOptions: { headerShown: false },
  },
  {
    component: FourTabsRippleColor,
    name: 'Four Tabs with ripple Color',
    platform: 'android',
  },
  {
    component: FourTabsNoAnimations,
    name: 'Four Tabs - no animations',
  },
  {
    component: FourTabsTransparentScrollEdgeAppearance,
    name: 'Four Tabs - Transparent scroll edge appearance',
    platform: 'ios',
  },
  {
    component: FourTabsOpaqueScrollEdgeAppearance,
    name: 'Four Tabs - Opaque scroll edge appearance',
    platform: 'ios',
  },
  {
    component: FourTabsWithBackgroundColor,
    name: 'Four Tabs - Custom Background Color of Tabs',
  },
  {
    component: FourTabsTranslucent,
    name: 'Four Tabs - Translucent tab bar',
    platform: 'android',
  },
  {
    component: FourTabsActiveIndicatorColor,
    name: 'Four Tabs - Active Indicator color',
  },
  {
    component: HiddenTab,
    name: 'Four Tabs - With Hidden Tab',
  },
  {
    component: NativeBottomTabsFreezeOnBlur,
    name: 'Native Bottom Tabs with freezeOnBlur',
  },
  {
    component: NativeBottomTabsSVGs,
    name: 'Native Bottom Tabs with SVG Icons',
  },
  {
    component: NativeBottomTabsUnmounting,
    name: 'Native Bottom Tabs unmounting',
  },
  {
    component: NativeBottomTabsRemoteIcons,
    name: 'Native Bottom Tabs with SVG Remote Icons',
  },
  {
    component: NativeBottomTabsCustomTabBar,
    name: 'Native Bottom Tabs with Custom Tab Bar',
  },
  { component: NativeBottomTabs, name: 'Native Bottom Tabs' },
  { component: JSBottomTabs, name: 'JS Bottom Tabs' },
  {
    component: JSBottomTabs,
    name: 'JS Bottom Tabs - No header',
    screenOptions: { headerShown: false },
  },
  { component: MaterialBottomTabs, name: 'Material (JS) Bottom Tabs' },
  { component: TintColorsExample, name: 'Tint Colors' },
  {
    component: BottomAccessoryView,
    name: 'Bottom Accessory View',
    screenOptions: { headerShown: false },
  },
  { component: FourTabsRightToLeft, name: 'Four Tabs - RTL' },
];

function App() {
  const navigation = useNavigation();
  return (
    <ScrollView>
      {examples
        .filter((example) =>
          'platform' in example ? example?.platform === Platform.OS : example
        )
        .map((example) => (
          <TouchableOpacity
            key={example.name}
            testID={example.name}
            style={styles.exampleTouchable}
            onPress={() => {
              //@ts-ignore
              navigation.navigate(example.name);
            }}
          >
            <Text style={styles.exampleText}>{example.name}</Text>
          </TouchableOpacity>
        ))}
    </ScrollView>
  );
}

const Stack = createStackNavigator();

const NativeStack = createNativeStackNavigator();

const defaultStack = Platform.OS === 'macos' ? 'js' : 'native';

export default function Navigation() {
  const [mode, setMode] = React.useState<'native' | 'js'>(defaultStack);

  const NavigationStack = mode === 'js' ? Stack : NativeStack;

  const navigationRef = useNavigationContainerRef();

  useLogger(navigationRef);

  return (
    <SafeAreaProvider>
      <NavigationContainer ref={navigationRef}>
        <NavigationStack.Navigator initialRouteName="BottomTabs Example">
          <NavigationStack.Screen
            name="BottomTabs Example"
            component={App}
            options={{
              headerRight: () => (
                <Button
                  onPress={() =>
                    Alert.alert(
                      'Alert',
                      `Do you want to change to the ${
                        mode === 'js' ? 'native stack' : 'js stack'
                      } ?`,
                      [
                        { text: 'No', onPress: () => {} },
                        {
                          text: 'Yes',
                          onPress: () => {
                            setMode(mode === 'js' ? 'native' : 'js');
                          },
                        },
                      ]
                    )
                  }
                  title={mode === 'js' ? 'JS' : 'NATIVE'}
                  color="blue"
                />
              ),
            }}
          />
          {examples
            .filter((example) =>
              'platform' in example
                ? example?.platform === Platform.OS
                : example
            )
            .map((example, index) => (
              <NavigationStack.Screen
                key={index}
                name={example.name}
                component={example.component}
                options={example.screenOptions}
              />
            ))}
        </NavigationStack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  exampleTouchable: {
    padding: 16,
  },
  exampleText: {
    fontSize: 16,
  },
});
