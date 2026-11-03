import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Article } from '../Screens/Article';
import { Albums } from '../Screens/Albums';
import { Contacts } from '../Screens/Contacts';
import { Chat } from '../Screens/Chat';

const Tab = createBottomTabNavigator();

function JSBottomTabs() {
  return (
    <Tab.Navigator screenOptions={{ headerShown: false }}>
      <Tab.Screen name="Article" component={Article} />
      <Tab.Screen name="Albums" component={Albums} />
      <Tab.Screen name="Contacts" component={Contacts} />
      <Tab.Screen name="Chat" component={Chat} />
    </Tab.Navigator>
  );
}

export default JSBottomTabs;
