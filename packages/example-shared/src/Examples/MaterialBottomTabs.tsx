import { createMaterialBottomTabNavigator } from 'react-native-paper/react-navigation';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';
import { Image, type ImageSourcePropType } from 'react-native';

const Tab = createMaterialBottomTabNavigator();

const TabBarIcon = ({ source }: { source: ImageSourcePropType }) => (
  <Image style={{ width: 20, height: 23 }} source={source} />
);

function MaterialBottomTabs() {
  return (
    <Tab.Navigator shifting>
      <Tab.Screen
        name="Article"
        component={Article}
        options={{
          tabBarIcon: () => (
            <TabBarIcon
              source={require('../../assets/icons/article_dark.png')}
            />
          ),
        }}
      />
      <Tab.Screen
        name="Albums"
        component={Albums}
        options={{
          tabBarIcon: () => (
            <TabBarIcon source={require('../../assets/icons/grid_dark.png')} />
          ),
        }}
      />
      <Tab.Screen
        name="Contacts"
        component={Contacts}
        options={{
          tabBarIcon: () => (
            <TabBarIcon
              source={require('../../assets/icons/person_dark.png')}
            />
          ),
        }}
      />
      <Tab.Screen
        name="Chat"
        component={Chat}
        options={{
          tabBarIcon: () => (
            <TabBarIcon source={require('../../assets/icons/chat_dark.png')} />
          ),
        }}
      />
    </Tab.Navigator>
  );
}

export default MaterialBottomTabs;
